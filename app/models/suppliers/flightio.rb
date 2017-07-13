class Suppliers::Flightio
  require "open-uri"
  require "uri"

  def search(origin,destination,date,search_history_id)
    if Rails.env.test?
        response = File.read("test/fixtures/files/domestic-flightio.log") 
        return {response: response, deeplink: "http://flightio.com/fa/"}
    end

    get_flight_url = "http://flightio.com/fa/Home/DomesticSearch"
    shamsi_date_object = date.to_date.to_parsi   
    shamsi_date = "#{shamsi_date_object}".tr("-","/") #convert it to 1396/02/26

    begin
      params = {'DOM_TripMode' => '1', 'DOM_SourceCityCode' => "#{origin.upcase}", 'DOM_SourceCityName' => '', 'DOM_DestinationCityCode'=>"#{destination.upcase}", 'DOM_DestinationCityName'=>'','DOM_DepartDate_Str' => "#{shamsi_date}", 'DOM_ReturnDate_Str' => '', 'DOM_AdultCount' => '1', 'DOM_ChildCount' => '0', 'DOM_InfantCount' => '0'}  
      SearchHistory.append_status(search_history_id,"R1(#{Time.now.strftime('%M:%S')})")
      #RestClient.post("#{URI.parse(get_flight_url)}", params)
      RestClient::Request.execute(method: :post, url: "#{URI.parse(get_flight_url)}",headers: {params: params}, proxy: nil)
    rescue RestClient::Exception => ex
      response  = ex.response.headers[:location] #the url redirected to another one
    rescue => e #this is for get socket error, DNS error
      SearchHistory.append_status(search_history_id,"failed:(#{Time.now.strftime('%M:%S')}) #{e.message}")
      return {status:false}
    end
    
    begin
      request_id = response[29..-1]
      search_flight_url = "http://flightio.com/fa/FlightResult/ListTable?FSL_Id="+ request_id
      deep_link = "http://flightio.com/fa/FlightPreview/Detail?FSL_Id=" + request_id + "&CombinationID="
      SearchHistory.append_status(search_history_id,"R2(#{Time.now.strftime('%M:%S')})")
      #second_response = RestClient.get("#{URI.parse(search_flight_url)}")
      second_response = RestClient::Request.execute(method: :get, url: "#{URI.parse(search_flight_url)}", proxy: nil)
    rescue
      SearchHistory.append_status(search_history_id,"failed:(#{Time.now.strftime('%M:%S')}) #{e.message}")
      return {status:false}
    end
    return {status:true, response: second_response, deeplink: deep_link}
  end

  def import_domestic_flights(response,route_id,origin,destination,date,search_history_id)
      flight_prices = Array.new()
      doc = Nokogiri::HTML(response[:response])
      doc = doc.xpath('//div[@class="search-result flights-boxs depart"]')
      SearchHistory.append_status(search_history_id,"Extracting(#{Time.now.strftime('%M:%S')})")
      doc.each do |flight|
        price = flight['amount']
        airline_code = flight['airline'].tr(",","")
        combination_id = flight['combinationid']
        deeplink_url = response[:deeplink]+combination_id
        departure_hour = flight['sourcedeparttime']
        
        departure_time_from = date +" "+ departure_hour + ":00:00"
        departure_time_to = date+" "+(departure_hour.to_i+1).to_s+":00:00"

        flight_id_list = Flight.where(route_id:route_id).where(airline_code:"#{airline_code}").where(departure_time: "#{departure_time_from}".."#{departure_time_to}")
        
        if flight_id_list.first.nil? #if true, then it means this flight is not available in our flight table
          next
        else
          flight_id = flight_id_list.first[:id]
        end
        
        #to prevent duplicate flight prices we compare flight prices before insert into database
        flight_price_so_far = flight_prices.select {|flight_price| flight_price.flight_id == flight_id}
        unless flight_price_so_far.empty? #check to see a flight price for given flight is exists
          if flight_price_so_far.first.price.to_i <= price.to_i #exist price is cheaper or equal to new price so ignore it
            next
          else
            flight_price_so_far.first.price = price #new price is cheaper, so update the old price and go to next price
            next
          end
        end
          
          flight_prices << FlightPrice.new(flight_id: "#{flight_id}", price: "#{price}", supplier:"flightio", flight_date:"#{date}", deep_link:"#{deeplink_url}")
      end #end of each loop
      
      SearchHistory.append_status(search_history_id,"Saving(#{Time.now.strftime('%M:%S')})")
      # first we should remove the old flight price archive 
      FlightPrice.delete_old_flight_prices("flightio",route_id,date) unless flight_prices.empty?
      # then bulk import enabled by a bulk import gem
      FlightPrice.import flight_prices 
      FlightPriceArchive.import flight_prices
      SearchHistory.append_status(search_history_id,"Success(#{Time.now.strftime('%M:%S')})")

  end

end