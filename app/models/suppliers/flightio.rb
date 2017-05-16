class Suppliers::Flightio
  require "open-uri"
  require "uri"

  @get_flight_url = "http://flightio.com/fa/Home/DomesticSearch"
  @search_flight_url = "http://flightio.com/fa/FlightResult/ListTable?FSL_Id="
  @deep_link = "http://flightio.com/fa/FlightResult/List?FSL_Id="

  def self.search(origin,destination,date)
    
    shamsi_date_object = date.to_date.to_parsi   
    shamsi_date = "#{shamsi_date_object}".tr("-","/") #convert it to 1396/02/26

    begin
      params = {'DOM_TripMode' => '1', 'DOM_SourceCityCode' => "#{origin.upcase}", 'DOM_SourceCityName' => '', 'DOM_DestinationCityCode'=>"#{destination.upcase}", 'DOM_DestinationCityName'=>'','DOM_DepartDate_Str' => "#{shamsi_date}", 'DOM_ReturnDate_Str' => '', 'DOM_AdultCount' => '1', 'DOM_ChildCount' => '0', 'DOM_InfantCount' => '0'}  
    RestClient.post("#{URI.parse(@get_flight_url)}", params)
    rescue RestClient::Exception => ex
      response  = ex.response.headers[:location] #the url redirected to another one
    end
    request_id = response[29..-1]
    @search_flight_url = @search_flight_url + request_id
    @deep_link = @deep_link + request_id
    second_response = RestClient.get("#{URI.parse(@search_flight_url)}")
    return {response: second_response, deeplink: @deep_link}
  end

end
