class Suppliers::Zoraq
    require "uri"
    require "rest-client"
    
    def search(origin,destination,date,search_history_id)
      if Rails.env.test?
        response = File.read("test/fixtures/files/domestic-zoraq.log") 
        return {response: response}
      end

      begin
        url = "http://zoraq.com/Flight/DeepLinkSearch"
  	    params = {'OrginLocationIata' => "#{origin.upcase}", 'DestLocationIata' => "#{destination.upcase}", 'DepartureGo' => "#{date}", 'Passengers[0].Type' =>'ADT', 'Passengers[0].Quantity'=>'1'}
        ActiveRecord::Base.connection_pool.with_connection do        
          SearchHistory.append_status(search_history_id,"R1(#{Time.now.strftime('%M:%S')})")
        end
        #response = RestClient.post("#{URI.parse(url)}", params)
        response = RestClient::Request.execute(method: :post, url: "#{URI.parse(url)}",headers: {params: params}, proxy: nil)
      rescue => e
        ActiveRecord::Base.connection_pool.with_connection do        
          SearchHistory.append_status(search_history_id,"failed:(#{Time.now.strftime('%M:%S')}) #{e.message}")
        end
          return {status:false}
      end
      return {status:true,response: response.body}
    end

    def import_domestic_flights(response,route_id,origin,destination,date,search_history_id)
      flight_prices = Array.new()
      json_response = JSON.parse(response[:response])
      ActiveRecord::Base.connection_pool.with_connection do        
        SearchHistory.append_status(search_history_id,"Extracting(#{Time.now.strftime('%M:%S')})")
      end
      json_response["PricedItineraries"].each do |flight|
        flight_number = airline_code = airplane_type = departure_date_time = flight_id = nil
        flight_legs = flight["OriginDestinationOptions"][0]["FlightSegments"]
      
        flight_legs.each do |leg|
          corrected_airline_code = airline_code_correction(leg["OperatingAirline"]["Code"])

          #to add airline code to flight number for some corrupted flight numbers
          #for example there is 4545 flight number which is not correct
          #the correct format is w54545
          if leg["FlightNumber"].include? corrected_airline_code
            correct_flight_number = leg["FlightNumber"]
          else
            correct_flight_number = corrected_airline_code+leg["FlightNumber"]
          end

          correct_flight_number = correct_flight_number.tr('.','') #sometimes zoraq responses with "." in start or end of a flight number

          flight_number = flight_number.nil? ? correct_flight_number : flight_number +"|"+correct_flight_number
          airline_code = airline_code.nil? ? corrected_airline_code : airline_code +"|"+corrected_airline_code
          airplane_type = airplane_type.nil? ? leg["OperatingAirline"]["Equipment"] : airplane_type +"|"+leg["OperatingAirline"]["Equipment"]
          #we need just first departre date time, so the other leg's departre time is commented
          departure_date_time = departure_date_time.nil? ? leg["DepartureDateTime"] : departure_date_time # +"|"+leg["DepartureDateTime"]
        end

        departure_time = parse_date(departure_date_time).utc.to_datetime
        departure_time = departure_time + ENV["IRAN_ADDITIONAL_TIMEZONE"].to_f.minutes # add 4:30 hours because zoraq date time is in iran time zone #.strftime("%H:%M")

        ActiveRecord::Base.connection_pool.with_connection do        
          flight_id = Flight.create_or_find_flight(route_id,flight_number,departure_time,airline_code,airplane_type)
        end

        departure_date = departure_time.strftime("%F")
        price = flight["AirItineraryPricingInfo"]["PTC_FareBreakdowns"][0]["PassengerFare"]["TotalFare"]["Amount"]
        deeplink_url = get_zoraq_deeplink(origin, destination,date,flight["AirItineraryPricingInfo"]["FareSourceCode"])
        
        #to prevent duplicate flight prices we compare flight prices before insert into database
        flight_price_so_far = flight_prices.select {|flight_price| flight_price.flight_id == flight_id}
        unless flight_price_so_far.empty? #check to see a flight price for given flight is exists
          if flight_price_so_far.first.price.to_i <= price.to_i #saved price is cheaper or equal to new price so we dont touch it
            next
          else
            flight_price_so_far.first.price = price #new price is cheaper, so update the old price and go to next price
            flight_price_so_far.first.deep_link = deeplink_url
            next
          end
        end

        ActiveRecord::Base.connection_pool.with_connection do        
          flight_prices << FlightPrice.new(flight_id: "#{flight_id}", price: "#{price}", supplier:"zoraq", flight_date:"#{departure_date}", deep_link:"#{deeplink_url}" )
        end

      end #end of each loop
      
      unless flight_prices.empty?
        ActiveRecord::Base.connection_pool.with_connection do        
          #SearchHistory.append_status(search_history_id,"Deleting(#{Time.now.strftime('%M:%S')})")
          #first we should remove the old flight price archive 
          FlightPrice.delete_old_flight_prices("zoraq",route_id,date) 
          #SearchHistory.append_status(search_history_id,"Importing(#{Time.now.strftime('%M:%S')})")
          #then bulk import enabled by a bulk import gem
          FlightPrice.import flight_prices
          #SearchHistory.append_status(search_history_id,"Archive(#{Time.now.strftime('%M:%S')})") 
          FlightPriceArchive.import flight_prices
          SearchHistory.append_status(search_history_id,"Success(#{Time.now.strftime('%M:%S')})")
        end
      else
        ActiveRecord::Base.connection_pool.with_connection do        
          SearchHistory.append_status(search_history_id,"empty response(#{Time.now.strftime('%M:%S')})")
        end
      end


  end

  def parse_date(datestring)
    seconds_since_epoch = datestring.scan(/[0-9]+/)[0].to_i / 1000.0
    return Time.at(seconds_since_epoch)
  end


  def airline_code_correction(airline_code)
    airlines ={
      "@1"=>"AK",
      "@2"=>"B9",
      "@3"=>"SEPAHAN",
      "@4"=>"hesa",
      "@5"=>"I3",
      "@7"=>"JI",
      "@8"=>"IV",
      "@9"=>"NV",
      "@A"=>"SE",
      "@B"=>"ZV",
      "ZZ"=>"SE",
      "SA"=>"SE"
		}
	  airlines[airline_code].nil? ? airline_code.upcase : airlines[airline_code]
  end

  def get_zoraq_deeplink(origin,destination,date,fare_source_code)
    if date == Date.today.to_s
      deeplink = "http://zoraq.com"+fare_source_code.to_s
    else
      country_name = "Iran"
      destination_city_english = City.list[destination.to_sym][:en].capitalize
      destination_city_farsi = City.list[destination.to_sym][:fa].capitalize
      origin_city_farsi = City.list[origin.to_sym][:fa].capitalize

      depart_date = date.tr("-","")[2..-1]
      return_date = ((date.to_date+1).to_s).tr("-","")[2..-1]

      deep_link = "http://zoraq.com/#{country_name}/#{destination_city_english}/Flights/?Origin=#{origin}%23&Destination=#{destination}%23&DepartDate=#{depart_date}&ReturnDate=#{return_date}&DestinationCity=#{destination_city_farsi}&OriginCity=#{origin_city_farsi}&Adult=1&Child=0&Infant=0&IsDirect=False&IteneryType=Dritect&CabinClass=Y&SearchType=DomesticFlights&UserSubmittedForm=True"
      #deep_link = "http://zoraq.com/Iran/Mashhad/Flights/?Origin=THR%23&Destination=MHD%23&DepartDate=170717&ReturnDate=170718&DestinationCity=علی&OriginCity=%D8%AA%D9%87%D8%B1%D8%A7%D9%86&Adult=1&Child=0&Infant=0&IsDirect=False&IteneryType=Dritect&CabinClass=Y&SearchType=DomesticFlights&UserSubmittedForm=True"
    end
  end

end