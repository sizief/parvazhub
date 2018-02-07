class Suppliers::Hipotrip < Suppliers::Base  
    require "uri"
    require "rest-client"
    
    def get_params
        {"origin_destination":[{
            "origin": "AAP#{origin.upcase}",
            "destination": "AAP#{destination.upcase}",
            "date": "#{date}"
            }
            ],
            "adult": 1,
            "child": 0,
            "infant":0,
            "flight_class":"Y"
           }
    end

    def register_search 
        begin
          url = "https://rest.hipotrip.com/api/search/flight"
          if Rails.env.test?
            response = {"request_id":"2473e8fcbacf4722","estimated_delay_time":5,"interval":2}
          else
            response = RestClient::Request.execute(method: :post, 
                                                    url: "#{URI.parse(url)}",
                                                    payload: get_params.to_json, 
                                                    proxy: nil,
                                                    headers: {:'Content-Type'=> "application/json"})
            response = JSON.parse response.body
          end
        rescue => e
          SearchHistory.append_status(search_history_id,"failed:(#{Time.now.strftime('%M:%S')}) #{e.message}")
          raise "first request error"
        end
        return response
      end
  
    def search_supplier 
      results = register_search 
      
      sleep results["estimated_delay_time"].to_f
      begin
        request_id = results["request_id"]
        url = "https://rest.hipotrip.com/api/search/flight?request_id=#{request_id}"
        if Rails.env.test?
          response = mock_results
        else
          response = RestClient::Request.execute(method: :get, 
                                                url: "#{URI.parse(url)}",
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
      request_id = json_response["request_id"]
      
      ActiveRecord::Base.connection_pool.with_connection do        
        SearchHistory.append_status(search_history_id,"Extracting(#{Time.now.strftime('%M:%S')})")
      end
      json_response["flights"][0..ENV["MAX_NUMBER_FLIGHT"].to_i].each do |flight|
        leg_data = flight_id = nil
        leg_data = prepare flight["origin_destination"][0]["segments"]
        
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
  
        price = flight["total_fare"][0]["total_price"] 
        price = (price/10).to_i
        deeplink_url = get_deeplink request_id, flight["result_id"] 
          
        flight_price_so_far = flight_prices.select {|flight_price| flight_price.flight_id == flight_id}
        unless flight_price_so_far.empty? 
          if flight_price_so_far.first.price.to_i <= price.to_i
            next
          else
            flight_price_so_far.first.price = price 
            flight_price_so_far.first.deep_link = deeplink_url
            next
          end
        end
  
        flight_prices << FlightPrice.new(flight_id: "#{flight_id}", price: "#{price}", supplier: supplier_name.downcase, flight_date:"#{date}", deep_link:"#{deeplink_url}" )
  
      end #end of each loop
        
      unless flight_prices.empty?
        ActiveRecord::Base.connection_pool.with_connection do 
          SearchHistory.append_status(search_history_id,"p done(#{Time.now.strftime('%M:%S')})")        
          
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
        airline_code = code_correction leg["airline"]["iata"]
        flight_number = (leg["airline"]["flight_number"].include? airline_code) ? leg["airline"]["flight_number"] : airline_code+leg["airline"]["flight_number"]
  
        flight_numbers << flight_number 
        airline_codes << airline_code
        airplane_types << leg["airline"]["aircraft_hid"]
        departure_date_times << leg["departure_datetime"].to_datetime
        arrival_date_times << leg["arrival_datetime"].to_datetime
        stops << leg["destination_airport_iata"]
        trip_duration += to_minutes leg["duration"]
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

    def code_correction code
      if code.upcase == "SHI"
        code = "SR"
      elsif code.upcase == "SH"
        code = "SE"
      else
        code = code
      end
      code
    end
  
    def to_minutes time_string
      total_time = 0
      time_string = time_string.split(":")
      total_time = time_string.first.to_i * 60
      total_time += time_string.second.to_i
    end
  
    def get_deeplink request_id, result_id
      "https://hipotrip.com/flight/book/#{request_id}/#{result_id}"
    end

  end