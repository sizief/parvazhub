class Suppliers::Flytoday < Suppliers::Base  
  require "uri"
  require "rest-client"
  
  def get_params
    shamsi_date = date.to_date.to_parsi.strftime "%Y-%m-%d"        
    params = {'OriginLocationCodes[0]' => "#{origin.upcase}", 
              'DestinationLocationCodes[0]' => "#{destination.upcase}", 
              'DepartureDateTimes[0]' => "#{shamsi_date}", 
              'DepartureDateTimes_lang[0]' => "",
              'DepartureDateTimeR' => "",
              'AdultCount' => 1,
              'ChildCount' => 0,
              'InfantCount' => 0,
              'CabinType' => 100,
              'Foreign_FlightType' => 'OneWay'}
  end

  def search_supplier 
    begin
      url = "https://www.flytoday.ir/flight/search/deeplinksearch"
    if Rails.env.test?
      response = mock_results
    else
      response = RestClient::Request.execute(method: :post, 
                                                url: "#{URI.parse(url)}",
                                                payload: get_params, 
                                                proxy: nil)
      response = response.body
    end
    rescue => e
      SearchHistory.append_status(search_history_id,"failed:(#{Time.now.strftime('%M:%S')}) #{e.message}")
      return {status:false}
    end
    return {status:true,response: response}
  end

  def import_flights(response,route_id,origin,destination,date,search_history_id)
    flight_id = nil
    flight_prices, flight_ids = Array.new(), Array.new()
   
    json_response = JSON.parse(response[:response])
    ActiveRecord::Base.connection_pool.with_connection do        
      SearchHistory.append_status(search_history_id,"Extracting(#{Time.now.strftime('%M:%S')})")
    end
    json_response["PricedItineraries"][0..ENV["MAX_NUMBER_FLIGHT"].to_i].each do |flight|
      leg_data = flight_id = nil
      leg_data = prepare flight["FlightSegments"]
      
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

      price = flight["PtcFareBreakdowns"][0]["TotalFareWithMarkupAndVat"]      
      price = (price/10).to_i
      deeplink_url = get_deeplink(flight["FareSourceCode"])
        
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

      flight_prices << FlightPrice.new(flight_id: "#{flight_id}", price: "#{price}", supplier:"flytoday", flight_date:"#{date}", deep_link:"#{deeplink_url}" )

    end #end of each loop
      
    unless flight_prices.empty?
      ActiveRecord::Base.connection_pool.with_connection do 
        SearchHistory.append_status(search_history_id,"p done(#{Time.now.strftime('%M:%S')})")        
        FlightPrice.delete_old_flight_prices("flytoday",route_id,date)
        SearchHistory.append_status(search_history_id,"d(#{Time.now.strftime('%M:%S')})")
        
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
      airline_code = leg["OperatingAirline"]
      flight_number = (leg["FlightNumber"].include? airline_code) ? leg["FlightNumber"] : airline_code+leg["FlightNumber"]

      flight_numbers << flight_number 
      airline_codes << airline_code
      airplane_types << leg["OperatingEquipment"]
      departure_date_times << parse_date(leg["DepartureDateTime"]).utc.to_datetime + ENV["IRAN_ADDITIONAL_TIMEZONE"].to_f.minutes # add 4:30 hours because flytoday date time is in iran time zone #.strftime("%H:%M")
      arrival_date_times << parse_date(leg["ArrivalDateTime"]).utc.to_datetime + ENV["IRAN_ADDITIONAL_TIMEZONE"].to_f.minutes
      stops << leg["ArrivalAirport"]
      trip_duration += to_minutes leg["JourneyDuration"]
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

  def to_minutes time_string
    total_time = 0
    time_string = time_string.split(":")
    total_time = time_string.first.to_i * 60
    total_time += time_string.second.to_i
  end

  def parse_date(datestring)
    seconds_since_epoch = datestring.scan(/[0-9]+/)[0].to_i / 1000.0
    return Time.at(seconds_since_epoch)
  end

  def get_deeplink(fare_source_code)
    "https://flytoday.ir/flight/book?fsc=#{fare_source_code}"
  end

end