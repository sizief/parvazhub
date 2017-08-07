class Suppliers::Ghasedak
    require "uri"
    require "rest-client"

  def search(origin,destination,date,search_history_id)
      if Rails.env.test?
        response = File.read("test/fixtures/files/domestic-ghasedak.log") 
        return {response: response}
      end

      begin

        url = "https://ghasedak24.com/api/GetAllFlights/?"
        date = date.to_date.to_s.gsub("-","/")  
        params = "from=#{origin.upcase}&to=#{destination.upcase}&fromDate=#{date}&toDate=#{date}&userName=sepehr&password=1234&cs=1"
        SearchHistory.append_status(search_history_id,"R1(#{Time.now.strftime('%M:%S')})")
        response = RestClient::Request.execute(method: :get, url: "#{URI.parse(url+params)}", proxy: nil,payload: params)
      rescue => e
        SearchHistory.append_status(search_history_id,"failed:(#{Time.now.strftime('%M:%S')}) #{e.message}")
        return {status:false}
      end
      return {status:true,response: response.body}
  end


    def import_domestic_flights(response,route_id,origin,destination,date,search_history_id)
      
      flight_prices = Array.new()
      json_response = JSON.parse(response[:response])
      SearchHistory.append_status(search_history_id,"Extracting(#{Time.now.strftime('%M:%S')})")
      
      json_response["data"].each do |flight|

        airline_code = get_airline_code(flight["Airline"])
        flight_number = airline_code+flight["FlightNo"]
        departure_time = flight["FlightDate"]
        departure_time = departure_time[0..9]+" "+departure_time[11..-1]

        airplane_type = flight["Airplane"]

        flight_id = Flight.create_or_find_flight(route_id,flight_number,departure_time,airline_code,airplane_type)
      
        price = (flight["Price"].to_f)/10
        deeplink_url = flight["ReserveLink"]
        
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

        flight_prices << FlightPrice.new(flight_id: "#{flight_id}", price: "#{price}", supplier:"ghasedak24", flight_date:"#{date}", deep_link:"#{deeplink_url}" )

      end #end of each loop
      
      unless flight_prices.empty?
        SearchHistory.append_status(search_history_id,"Deleting(#{Time.now.strftime('%M:%S')})")
        #first we should remove the old flight price archive 
        FlightPrice.delete_old_flight_prices("ghasedak24",route_id,date) 
        SearchHistory.append_status(search_history_id,"Importing(#{Time.now.strftime('%M:%S')})")
        #then bulk import enabled by a bulk import gem
        FlightPrice.import flight_prices
        SearchHistory.append_status(search_history_id,"Archive(#{Time.now.strftime('%M:%S')})") 
        FlightPriceArchive.import flight_prices
        SearchHistory.append_status(search_history_id,"Success(#{Time.now.strftime('%M:%S')})")
      else
        SearchHistory.append_status(search_history_id,"empty response(#{Time.now.strftime('%M:%S')})")
      end


  end

  def get_airline_code(airline_code)
    airlines ={
      "RV"=>"IV"
		}
	airlines[airline_code].nil? ? airline_code : airlines[airline_code]
  end


end