class Suppliers::Sepehr
    require "uri"
    require "rest-client"
=begin

    
    def search(origin,destination,date,search_history_id)
      if Rails.env.test?
        response = File.read("test/fixtures/files/domestic-sepehr.log") 
        return {response: response}
      end

      begin
        url = "http://api.sepehr.in/Api/Air_Availability"
        body = {"username":"Parvazhub","password":"@#Parv858azhub%$","origin":"#{origin}","destination":"#{destination}","DepartureDate":"#{date}","Adult":1}
          ActiveRecord::Base.connection_pool.with_connection do        
          SearchHistory.append_status(search_history_id,"R1(#{Time.now.strftime('%M:%S')})")
        end
        response = RestClient::Request.execute(method: :post, url: "#{URI.parse(url)}", payload: body.to_json, headers: {:'Content-Type'=> "application/json"}) 
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
      flight_prices = Array.new()
      json_response = JSON.parse(response[:response])
      ActiveRecord::Base.connection_pool.with_connection do        
        SearchHistory.append_status(search_history_id,"Extracting(#{Time.now.strftime('%M:%S')})")
      end
      json_response["FlightList"].each do |flight|
        airline_code = get_airline_code(flight["AirlineCode"].upcase)
        flight_number = airline_code + flight["FlightNumber"]
        departure_time = flight["Departure"][0..9]+" "+flight["Departure"][11..-1]+":00"
        airplane_type = nil
    
        ActiveRecord::Base.connection_pool.with_connection do        
          flight_id = Flight.create_or_find_flight(route_id,flight_number,departure_time,airline_code,airplane_type)
        end

        price = (flight["PriceList"].first["Total"])/10
        deeplink_url = get_deeplink(origin, destination,date)
        
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
          flight_prices << FlightPrice.new(flight_id: "#{flight_id}", price: "#{price}", supplier:"sepehr", flight_date:"#{date}", deep_link:"#{deeplink_url}" )
        end

      end #end of each loop
      
      unless flight_prices.empty?
        ActiveRecord::Base.connection_pool.with_connection do        
          FlightPrice.delete_old_flight_prices("sepehr",route_id,date) 
          FlightPrice.import flight_prices
          FlightPriceArchive.archive flight_prices
          SearchHistory.append_status(search_history_id,"Success(#{Time.now.strftime('%M:%S')})")
        end
      else
        ActiveRecord::Base.connection_pool.with_connection do        
          SearchHistory.append_status(search_history_id,"empty response(#{Time.now.strftime('%M:%S')})")
        end
      end


  end

  def get_airline_code(airline_code)
    airlines ={ 
      "SA"=>"SE",
      "ZZ"=>"SE",
      "ATR"=>"AK",
      "RZ"=>"SE",
      "RV"=>"IV"
		}
	airlines[airline_code].nil? ? airline_code : airlines[airline_code]
  end

  def get_deeplink(origin,destination,date)
    shamsi_date = date.to_date.to_parsi.to_s    
    deeplink = "http://sepehr.in/searchflight/#{origin}-#{destination}/#{shamsi_date}/1-0-0"
  end
=end
end