class Suppliers::Ghasedak
    require "uri"
    require "rest-client"

  def search(origin,destination,date,search_history_id)
      if Rails.env.test?
        response = File.read("test/fixtures/files/domestic-ghasedak.log") 
        return {response: response}
      end

      begin
        url = "https://ghasedak24.com/oob/thirdparty/search"
        date = date.to_date.to_parsi.to_s.gsub("-","/")  
        params = {'from' => "#{origin.upcase}", 'to' => "#{destination.upcase}", 'date' => "#{date}", 'number'=>'1','Oauth-Token'=>"89541f96-79d7-11e7-8fc9-000c29ff45b7"}
        SearchHistory.append_status(search_history_id,"R1(#{Time.now.strftime('%M:%S')})")
        response = RestClient::Request.execute(method: :post, url: "#{URI.parse(url)}",headers: {:'Oauth-Token'=> "955db966-79da-11e7-9ac5-000c29ff45b7"}, proxy: nil,payload: params)
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
                
        airline_code = get_airline_code(flight["airline_id"])
        next if airline_code.nil?

        flight_number = airline_code+flight["flight_no"]
        departure_time = Time.at(flight["date"].to_f).to_time #+ ENV["IRAN_ADDITIONAL_TIMEZONE"].to_f.minutes
        departure_time = departure_time.to_s[0..18]
        airplane_type = flight["aircraft"]

        flight_id = Flight.create_or_find_flight(route_id,flight_number,departure_time,airline_code,airplane_type)
      
        price = flight["price"]
        deeplink_url = "http://ghasedak24.com/flight/"+flight["ticket_id"]
        
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

  def get_airline_code(id)
    airlines ={"2"=>"W5",
		    "31"=>"AK", 
			"11"=>"B9", 
			"10"=>"I3", 
			"1572"=>"JI", 
      "1573"=>"IV", 
      "5"=>"IV", 
			"34"=>"NV", 
			"1582"=>"SE", 
			"9"=>"ZV",
			"1"=>"HH",
			"30"=>"QB",
			"3"=>"Y9",
			"29"=>"EP",
			"4"=>"IR",
			"1583"=>"SR"
		}
	airlines[id].nil? ? nil : airlines[id]
  end


end