class Suppliers::Zoraq
    require "uri"
    require "rest-client"
    
    def search(origin,destination,date)
      if Rails.env.test?
        response = File.read("test/fixtures/files/domestic-zoraq.log") 
        return {response: response}
      end

      begin
        url = "http://zoraq.com/Flight/DeepLinkSearch"
  	    params = {'OrginLocationIata' => "#{origin.upcase}", 'DestLocationIata' => "#{destination.upcase}", 'DepartureGo' => "#{date}", 'Passengers[0].Type' =>'ADT', 'Passengers[0].Quantity'=>'1'}
        #response = RestClient.post("#{URI.parse(url)}", params)
        response = RestClient::Request.execute(method: :post, url: "#{URI.parse(url)}",headers: {params: params}, timeout:  ENV["SUPPLIER_TIMEOUT"].to_f)
      rescue 
        return {status:false,response:"only request: #{e.message}. using proxy: no"}
      end

      return {response: response.body}
    end

    def import_domestic_flights(response,route_id,origin,destination,date)
      flight_prices = Array.new()
      json_response = JSON.parse(response[:response])
      json_response["PricedItineraries"].each do |flight|
        flight_number = airline_code = airplane_type = departure_date_time  = nil
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

        flight_id = Flight.create_or_find_flight(route_id,flight_number,departure_time,airline_code,airplane_type)

        departure_date = departure_time.strftime("%F")
        price = flight["AirItineraryPricingInfo"]["PTC_FareBreakdowns"][0]["PassengerFare"]["TotalFare"]["Amount"]
        deeplink_url = "http://zoraq.com"+flight["AirItineraryPricingInfo"]["FareSourceCode"]
        
        #to prevent duplicate flight prices we compare flight prices before insert into database
        flight_price_so_far = flight_prices.select {|flight_price| flight_price.flight_id == flight_id}
        unless flight_price_so_far.empty? #check to see a flight price for given flight is exists
          if flight_price_so_far.first.price.to_i <= price.to_i #saved price is cheaper or equal to new price so we dont touch it
            next
          else
            flight_price_so_far.first.price = price #new price is cheaper, so update the old price and go to next price
            next
          end
        end

        flight_prices << FlightPrice.new(flight_id: "#{flight_id}", price: "#{price}", supplier:"zoraq", flight_date:"#{departure_date}", deep_link:"#{deeplink_url}" )

      end #end of each loop

      # first we should remove the old flight price archive 
      FlightPrice.delete_old_flight_prices("zoraq",route_id,date) unless flight_prices.empty?
      # then bulk import enabled by a bulk import gem
      FlightPrice.import flight_prices 
      FlightPriceArchive.import flight_prices

  end

  def parse_date(datestring)
    seconds_since_epoch = datestring.scan(/[0-9]+/)[0].to_i / 1000.0
    return Time.at(seconds_since_epoch)
  end


  def airline_code_correction(zoraq_airline_code)
    airline_codes = {
      "AK":"@1", #Atrak Airlines
      "B9":"@2", #Iran Airtour
      "sepahan":"@3", #Sepahan Airlines
      "hesa":"@4", #Hesa 
      "I3":"@5", #ATA Airlines
      "JI":"@7", #Meraj
      "IV":"@8", #Caspian Airlines
      "NV":"@9", #Iranian Naft Airlines
      "saha":"@A", #Saha
      "ZV":"@B" #Zagros 
    }
    if airline_codes.key("#{zoraq_airline_code}").nil?
      return zoraq_airline_code.upcase
    else
      return airline_codes.key("#{zoraq_airline_code}").to_s.upcase
    end
  end


end