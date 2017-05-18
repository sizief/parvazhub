class Suppliers::Flightio
  require "open-uri"
  require "uri"

  def search(origin,destination,date)

    get_flight_url = "http://flightio.com/fa/Home/DomesticSearch"
    shamsi_date_object = date.to_date.to_parsi   
    shamsi_date = "#{shamsi_date_object}".tr("-","/") #convert it to 1396/02/26

    begin
      params = {'DOM_TripMode' => '1', 'DOM_SourceCityCode' => "#{origin.upcase}", 'DOM_SourceCityName' => '', 'DOM_DestinationCityCode'=>"#{destination.upcase}", 'DOM_DestinationCityName'=>'','DOM_DepartDate_Str' => "#{shamsi_date}", 'DOM_ReturnDate_Str' => '', 'DOM_AdultCount' => '1', 'DOM_ChildCount' => '0', 'DOM_InfantCount' => '0'}  
      RestClient.post("#{URI.parse(get_flight_url)}", params)
      rescue RestClient::Exception => ex
        response  = ex.response.headers[:location] #the url redirected to another one
      end
      request_id = response[29..-1]
      search_flight_url = "http://flightio.com/fa/FlightResult/ListTable?FSL_Id="+ request_id
      deep_link = "http://flightio.com/fa/FlightResult/List?FSL_Id=" + request_id
      second_response = RestClient.get("#{URI.parse(search_flight_url)}")
      return {response: second_response, deeplink: deep_link}
  end

  def import_domestic_flights(response,route_id,origin,destination,date)
      doc = Nokogiri::HTML(response[:response])
      doc = doc.xpath('//div[@class="search-result flights-boxs depart"]')
      doc.each do |flight|
        price = flight['amount']
        airline_code = flight['airline'].tr(",","")
        deeplink_url = response[:deeplink]
        departure_hour = flight['sourcedeparttime']
        
        departure_time_from = date +" "+ departure_hour + ":00:00"
        departure_time_to = date+" "+(departure_hour.to_i+1).to_s+":00:00"
        flight_id_list = Flight.where(route_id:route_id).where(airline_code:"#{airline_code}").where(departure_time: "#{departure_time_from}".."#{departure_time_to}")
        
        if flight_id_list.first.nil?
          next
        else
          flight_id = flight_id_list.first[:id]
        end

        FlightPrice.create(flight_id: "#{flight_id}", price: "#{price}", supplier:"flightio", flight_date:"#{date}", deep_link:"#{deeplink_url}"  )
      end #end of each loop
  end


end
