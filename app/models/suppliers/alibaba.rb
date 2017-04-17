class Suppliers::Alibaba
  require "open-uri"
  @search_flight_url = "http://www.alibaba.ir/api/searchFlight?"
  @get_flight_url = "https://www.alibaba.ir/api/GetFlight?"

  def self.search(origin,destination,date)
    
    shamsi_date = date.to_date.to_parsi   
    begin
      search_flight_params = "ffrom=#{origin.upcase}&fto=#{destination.upcase}&datefrom=#{shamsi_date}&adult=1&child=0&infant=0"
      search_url = @search_flight_url+search_flight_params
      first_response = RestClient.get("#{search_url}")
    rescue
      raise "Time out for Alibaba" 
    end

    request_id = JSON.parse(first_response)["RequestId"]
    get_flight_params = "id=#{request_id}&last=0&ffrom=#{origin}&fto=#{destination}&datefrom=#{shamsi_date}&count=1&interval=1&isReturn=false&isNew=true"
    flight_url = @get_flight_url+get_flight_params
    second_response = RestClient.get("#{flight_url}")

  end
end
