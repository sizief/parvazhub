class Suppliers::Safarestan < Suppliers::Base  
    require "uri"
    require "rest-client"
    require 'rbzip2'

    
    def get_params
      {"apikey":"c9672995-2d2d-11e7-bc7a-001c429a2edb",
        "uid":"",
        "clientVersion":4,
        "productType":"localFlight",
        "searchFilter":{
            "sourceAirportCode":"#{origin.upcase}",
            "targetAirportCode":"#{destination.upcase}",
            "sourceAllinFromCity":true,
            "targetAllinFromCity":true,
            "leaveDate":date,
            "adultCount":1,
            "childCount":0,
            "infantCount":0,
            "oneWay":true,
            "productType":"localFlight",
            "compressed":true,
            "expireTime":0,
            "validTimeout":0,
            "isNew":true
        },
        "deviceInfo":{}
      }
    end
  
    def search_supplier 
      begin
        url = "http://mobileapp.safarestan.com/api/search"
        if Rails.env.test?
          response = mock_results
        else
          response = RestClient::Request.execute(method: :post, 
                                                  url: "#{URI.parse(url)}",
                                                  payload: get_params.to_json, 
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
     
      ActiveRecord::Base.connection_pool.with_connection do        
        SearchHistory.append_status(search_history_id,"Extracting(#{Time.now.strftime('%M:%S')})")
      end
      
      json_response = decode(JSON.parse(response[:response]))
      json_response[0..ENV["MAX_NUMBER_FLIGHT"].to_i].each do |flight|
        leg_data = flight_id = nil
        leg_data = prepare flight
        flight_id = find_flight_id leg_data,route_id
        
        next if ((leg_data.nil?) or (flight_id.nil?))
        flight_ids << flight_id
  
        price = (flight["singleAdultFinalPrice"]/10).to_i     
        deeplink_url = get_deeplink
          
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
  
    


    private
    def find_flight_id leg_data,route_id
      flights, flight_id = nil, nil
      departure_time_from = (leg_data[:departure_date_time]).strftime('%Y-%m-%d  %H:%M:%S').to_s
      departure_time_to = (leg_data[:departure_date_time] + (0.04)).strftime('%Y-%m-%d  %H:%M:%S').to_s
      ActiveRecord::Base.connection_pool.with_connection do 
        flights = Flight.where(route_id: route_id).where(airline_code: leg_data[:airline_code]).where(departure_time: "#{departure_time_from}".."#{departure_time_to}")
      end

      flight_id = flights.first[:id] unless flights.empty?   
    end

    def decode response
      if response["result"]["compressed"]
        temp = Base64.decode64 response["result"]["products"]
        response = RBzip2.default_adapter::Decompressor.new(StringIO.new(temp.to_s))
        response = JSON.parse response.read
      else
        response = response["result"]["products"]
      end
    end

    def prepare leg
      {
        airline_code: leg["airlineCode"],
        departure_date_time: leg["departureTime"].to_datetime,
        arrival_date_time: leg["arrivalTime"].to_datetime,
        trip_duration: leg["duration"]
      }
    end

    def get_deeplink
      "https://www.safarestan.com/"
    end
  
  end