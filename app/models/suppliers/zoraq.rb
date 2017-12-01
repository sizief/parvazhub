class Suppliers::Zoraq < Suppliers::Base  
  require "uri"
  require "rest-client"
    
  def search_supplier
      if Rails.env.test?
        if Route.select(:international).find_by(origin: origin, destination: destination).international
          file = "international-zoraq.log"
        else
          file = "domestic-zoraq.log"
        end
          response = File.read("test/fixtures/files/"+file) 
        return {response: response}
      end

      begin
        url = "http://zoraq.com/Flight/DeepLinkSearch"
  	    params = {'OrginLocationIata' => "#{origin.upcase}", 'DestLocationIata' => "#{destination.upcase}", 'DepartureGo' => "#{date}", 'Passengers[0].Type' =>'ADT', 'Passengers[0].Quantity'=>'1'}
        response = RestClient::Request.execute(method: :post, url: "#{URI.parse(url)}",headers: {params: params}, proxy: nil)
      rescue => e
        ActiveRecord::Base.connection_pool.with_connection do        
          SearchHistory.append_status(search_history_id,"failed:(#{Time.now.strftime('%M:%S')}) #{e.message}")
        end
        return {status:false}
      end
      return {status:true,response: response.body}
  end

  def import_flights(response,route_id,origin,destination,date,search_history_id)
    flight_id = nil
    flight_prices, flight_ids = Array.new(), Array.new()
    origin_object = City.find_by(city_code: origin)
    destination_object = City.find_by(city_code: destination)

    json_response = JSON.parse(response[:response])
    ActiveRecord::Base.connection_pool.with_connection do        
      SearchHistory.append_status(search_history_id,"Extracting(#{Time.now.strftime('%M:%S')})")
    end
    json_response["PricedItineraries"].each do |flight|
      leg_data = flight_id = nil
      flight_legs = flight["OriginDestinationOptions"][0]["FlightSegments"]
      leg_data = prepare flight_legs
      
      next if leg_data.nil?      
      ActiveRecord::Base.connection_pool.with_connection do        
          flight_id = Flight.create_or_find_flight(route_id,
          leg_data[:flight_number].join(","),
          leg_data[:departure_date_time].first,
          leg_data[:airline_code].join(","),
          leg_data[:airplane_type].join(","),
          leg_data[:arrival_date_time].last,
          leg_data[:stop].join(","),
          leg_data[:trip_duration])
      end
      flight_ids << flight_id      

      departure_date = leg_data[:departure_date_time].first.strftime("%F")
      price = flight["AirItineraryPricingInfo"]["PTC_FareBreakdowns"][0]["PassengerFare"]["TotalFare"]["Amount"]
      deeplink_url = get_zoraq_deeplink(origin_object, destination_object,date,flight["AirItineraryPricingInfo"]["FareSourceCode"])
        
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

      flight_prices << FlightPrice.new(flight_id: "#{flight_id}", price: "#{price}", supplier:"zoraq", flight_date:"#{departure_date}", deep_link:"#{deeplink_url}" )

    end #end of each loop
      
    unless flight_prices.empty?
      ActiveRecord::Base.connection_pool.with_connection do 
        SearchHistory.append_status(search_history_id,"p done(#{Time.now.strftime('%M:%S')})")        
        FlightPrice.delete_old_flight_prices("zoraq",route_id,date)
        SearchHistory.append_status(search_history_id,"delete(#{Time.now.strftime('%M:%S')})")
        
        FlightPrice.import flight_prices, validate: false
        SearchHistory.append_status(search_history_id,"fp(#{Time.now.strftime('%M:%S')})")
        
        FlightPriceArchive.archive flight_prices
        SearchHistory.append_status(search_history_id,"Success(#{Time.now.strftime('%M:%S')})")
      end
    else
      ActiveRecord::Base.connection_pool.with_connection do        
        SearchHistory.append_status(search_history_id,"empty (#{Time.now.strftime('%M:%S')})")
      end
    end
    return flight_ids
  end

  def prepare flight_legs
    flight_numbers, airline_codes, airplane_types, departure_date_times, arrival_date_times, stops = Array.new, Array.new, Array.new, Array.new, Array.new, Array.new
    trip_duration = 0
    flight_legs.each do |leg|
      airline_code = airline_code_correction(leg["OperatingAirline"]["Code"])
      flight_number = (leg["FlightNumber"].include? airline_code) ? leg["FlightNumber"] : airline_code+leg["FlightNumber"]
      flight_number = flight_number.tr('.','') #sometimes zoraq responses with "." in start or end of a flight number

      flight_numbers << flight_number 
      airline_codes << airline_code
      airplane_types << leg["OperatingAirline"]["Equipment"]
      departure_date_times << parse_date(leg["DepartureDateTime"]).utc.to_datetime + ENV["IRAN_ADDITIONAL_TIMEZONE"].to_f.minutes # add 4:30 hours because zoraq date time is in iran time zone #.strftime("%H:%M")
      arrival_date_times << parse_date(leg["ArrivalDateTime"]).utc.to_datetime + ENV["IRAN_ADDITIONAL_TIMEZONE"].to_f.minutes
      stops << leg["ArrivalAirportLocationCode"]
      trip_duration += leg["JourneyDuration"]
    end
    
    trip_duration += calculate_stopover_duration(departure_date_times,arrival_date_times)
    return {flight_number: flight_numbers,
            airline_code: airline_codes,
            airplane_type: airplane_types,
            departure_date_time: departure_date_times,
            arrival_date_time: arrival_date_times,
            stop: stops,
            trip_duration: trip_duration}
  end

  def calculate_stopover_duration (departures,arrivals)
    duration = 0    
    if departures.count > 1
      departures.each_with_index do |departure,index|
        next if index == 0
        duration += ((departure - arrivals[index-1])*24*60).to_i        
      end
    end
    duration
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

  def get_zoraq_deeplink(origin_object,destination_object,date,fare_source_code)
    if date == Date.today.to_s
      deeplink = "http://zoraq.com"+fare_source_code.to_s
    else
      country_name = "Iran"
      destination_city_english = destination_object.english_name.capitalize
      destination_city_farsi =  destination_object.persian_name
      origin_city_farsi =  origin_object.persian_name

      depart_date = date.tr("-","")[2..-1]
      return_date = ((date.to_date+1).to_s).tr("-","")[2..-1]

      deep_link = "http://zoraq.com/#{country_name}/#{destination_city_english}/Flights/?Origin=#{origin}%23&Destination=#{destination}%23&DepartDate=#{depart_date}&ReturnDate=#{return_date}&DestinationCity=#{destination_city_farsi}&OriginCity=#{origin_city_farsi}&Adult=1&Child=0&Infant=0&IsDirect=False&IteneryType=Dritect&CabinClass=Y&SearchType=DomesticFlights&UserSubmittedForm=True"
      #deep_link = "http://zoraq.com/Iran/Mashhad/Flights/?Origin=THR%23&Destination=MHD%23&DepartDate=170717&ReturnDate=170718&DestinationCity=علی&OriginCity=%D8%AA%D9%87%D8%B1%D8%A7%D9%86&Adult=1&Child=0&Infant=0&IsDirect=False&IteneryType=Dritect&CabinClass=Y&SearchType=DomesticFlights&UserSubmittedForm=True"
    end
  end

end