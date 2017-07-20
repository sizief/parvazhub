class Suppliers::Safarme
    require "uri"
    require "rest-client"

    @@search_url = "http://webapidevicebankgetway.safarme.com/api/Device_Reservation_Flight/SearchFlight?"
    
    def send_request (origin,destination,safarme_template_date,search_history_id,flight_type)
      begin
        params = "ApiSiteId=18F1FBCA-32F6-48B6-AF76-7243C6013668&SourceAbbrivation=#{origin.upcase}&DestinationAbbrivation=#{destination.upcase}&flightdate=#{safarme_template_date}&count=1&AdultCount=1&InfantCount=0&FlightType=#{flight_type}"
        search_url = @@search_url+params
        SearchHistory.append_status(search_history_id,"R#{flight_type}(#{Time.now.strftime('%M:%S')})")
        
        if Rails.env.test?
          response = File.read("test/fixtures/files/domestic-safarme.log")
        else 
          response = RestClient::Request.execute(method: :get, url: "#{URI.parse(search_url)}", proxy: nil)
          response = response.body
        end
      rescue => e
        SearchHistory.append_status(search_history_id,"failed:(#{Time.now.strftime('%M:%S')}) #{e.message}")
        return {status:false}
      end
      return response
    end

    def search(origin,destination,date,search_history_id)
      safarme_template_date = (date.to_datetime.to_s)[0..18]
      first_response = send_request(origin,destination,safarme_template_date,search_history_id,"1")
      second_response = send_request(origin,destination,safarme_template_date,search_history_id,"2")
      response = JSON.parse(first_response) + JSON.parse(second_response)
      return {status:true,response: response}
    end

    def import_domestic_flights(response,route_id,origin,destination,date,search_history_id)
      
      flight_prices = Array.new()
      SearchHistory.append_status(search_history_id,"Extracting(#{Time.now.strftime('%M:%S')})")
      
      response[:response].each do |flight|
        airline_code = get_airline_code(flight["AirLineID"])
        flight_number = airline_code + (flight["TitleFlight"].delete("^0-9"))
        departure_time = date + " " + flight["startTime"]
        airplane_type = ""
        price = flight["price"]/10
        deeplink_url = "http://safarme.com"
        flight_id = Flight.create_or_find_flight(route_id,flight_number,departure_time,airline_code,airplane_type)

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

        flight_prices << FlightPrice.new(flight_id: "#{flight_id}", price: "#{price}", supplier:"safarme", flight_date:"#{date}", deep_link:"#{deeplink_url}" )

      end #end of each loop
      
      unless flight_prices.empty?
        #SearchHistory.append_status(search_history_id,"Deleting(#{Time.now.strftime('%M:%S')})")
        #first we should remove the old flight price archive 
        FlightPrice.delete_old_flight_prices("safarme",route_id,date)
        #SearchHistory.append_status(search_history_id,"Importing(#{Time.now.strftime('%M:%S')})")
        #then bulk import enabled by a bulk import gem
        FlightPrice.import flight_prices
        #SearchHistory.append_status(search_history_id,"Archive(#{Time.now.strftime('%M:%S')})") 
        FlightPriceArchive.import flight_prices
        SearchHistory.append_status(search_history_id,"Success(#{Time.now.strftime('%M:%S')})")
      else
        SearchHistory.append_status(search_history_id,"empty response(#{Time.now.strftime('%M:%S')})")
      end

  end

  def get_airline_code(safarme_internal_code)
    airlines ={"5a9b4784-ded0-4fc0-b479-9294d4e2c0c3"=>"W5",
		"84309f8d-1a6a-491b-bec6-57aa42748009"=>"AK", 
			"43fdbf67-7c3e-4da9-bcfd-2ce4ed3bd987"=>"B9", 
			"3d26ded2-ce83-4e90-b2a4-827f3c1b4c9e"=>"I3", 
			"ff971cf7-dd37-49c5-87c9-71597d0fb297"=>"JI", 
			"2a671594-be4b-4a6c-9ff0-fbca720d7de1"=>"IV", 
			"ac5f813e-507c-4c75-998d-63fca4aa891d"=>"Nv", 
			"403babc0-cd2b-4c50-95bc-fab21a408e6f"=>"SE", 
			"b76a53dd-661a-4329-adb5-15cd191e698a"=>"ZV",
			"1784a7b0-d7da-4f57-a33f-69d64d778bcf"=>"HH",
			"be9bc96f-ae32-43c0-a009-19c3dbb30e00"=>"QB",
			"de1f05e1-a513-4400-b2f1-29d1141a0a27"=>"Y9",
			"d0ea772a-36c7-44f0-9644-9f075e4f514e"=>"EP",
			"6ca2226d-6bab-4abb-8039-63155ff26464"=>"IR",
			"661b0e4a-01c9-49dc-a6ef-532996665532"=>"SR"
		}
	airlines[safarme_internal_code].nil? ? safarme_internal_code : airlines[safarme_internal_code]
  end

end