class Suppliers::Trip
  require "uri"
  require "rest-client"

    def send_request (origin,destination,date,search_history_id,provider)
      if Rails.env.test?
        response = File.read("test/fixtures/files/domestic-trip.log") 
        return response
      end

      params = "src=#{origin.upcase}&isCityCodeSrc=true&dst=#{destination.upcase}&isCityCodeDst=true&class=e&depDate=#{date.upcase}&retDate=&adt=1&chd=0&inf=0&provider=#{provider}"
      search_url = "http://www.trip.ir/flightResult?" + params
      
       
      begin
        response = RestClient::Request.execute(method: :get, url: "#{URI.parse(search_url)}", proxy: nil)
        response = response.body
      rescue => e
        return nil
      end
      return response
    end

    def search(origin,destination,date,search_history_id)
      response = nil
      threads = []

      [6,8,10,12].each do |provider|
        
        ActiveRecord::Base.connection_pool.with_connection do
          SearchHistory.append_status(search_history_id,"R#{provider}(#{Time.now.strftime('%M:%S')})")
        end
        threads << Thread.new do
          provider_response = send_request(origin,destination,date,search_history_id,provider)
          unless provider_response.nil? #there is a response from provider
            if response.nil? #the first provider response
              response = JSON.parse(provider_response)["flights"] 
            else
              response = response + JSON.parse(provider_response)["flights"] 
            end
          end 
        end
 
      end
      
      threads.each do |thread|
        thread.join
      end

      unless response.nil?
        return {status:true,response: response}
      else
        return {status:false}
      end
    
    end

    def import_domestic_flights(response,route_id,origin,destination,date,search_history_id)
      flight_id = nil
      flight_prices = Array.new()
      ActiveRecord::Base.connection_pool.with_connection do
        SearchHistory.append_status(search_history_id,"Extracting(#{Time.now.strftime('%M:%S')})")
      end
      
      response[:response].each do |flight|
        airline_code = get_airline_code(flight["legs"][0]["operatorCode"])
        next if airline_code.nil?
        flight_number = airline_code + flight_number_correction(flight["legs"][0]["flightNo"],airline_code)
        departure_time = flight["legs"][0]["departureTime"] + ":00"
        airplane_type = ""
        price = flight["fares"]["total"]["price"]
        deeplink_url = get_deep_link(origin,destination,date)
        ActiveRecord::Base.connection_pool.with_connection do
          flight_id = Flight.create_or_find_flight(route_id,flight_number,departure_time,airline_code,airplane_type)
        end

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

        ActiveRecord::Base.connection_pool.with_connection do
          flight_prices << FlightPrice.new(flight_id: "#{flight_id}", price: "#{price}", supplier:"trip", flight_date:"#{date}", deep_link:"#{deeplink_url}" )
        end

      end #end of each loop
      
      unless flight_prices.empty?
        ActiveRecord::Base.connection_pool.with_connection do
          #SearchHistory.append_status(search_history_id,"Deleting(#{Time.now.strftime('%M:%S')})")
          #first we should remove the old flight price archive 
          FlightPrice.delete_old_flight_prices("trip",route_id,date)
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

  def get_deep_link(origin,destination,date)
    link = "http://www.trip.ir/flightSearch?src=#{origin.upcase}&isCityCodeSrc=true&dst=#{destination.upcase}&isCityCodeDst=true&class=e&depDate=#{date.upcase}&retDate=&adt=1&chd=0&inf=0"
  end

  def flight_number_correction(flight_number,airline_code)
    flight_number = flight_number.sub(airline_code,"")  if flight_number.include? airline_code
    return flight_number.gsub(/[^\d,\.]/, '')        
  end

  def get_airline_code(airline_code)
    airlines ={
      "RV"=>"IV",
      "SA"=>"SE"
		}
	airlines[airline_code].nil? ? airline_code : airlines[airline_code]
  end

end