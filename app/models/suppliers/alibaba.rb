class Suppliers::Alibaba
@search_flight_url = "http://www.alibaba.ir/api/searchFlight/?"
@get_flight_url = "https://www.alibaba.ir/api/GetFlight/?"

  def self.search(origin,destination,date)
    require "open-uri"
    shamsi_date = date.to_date.to_parsi   
    begin
      search_flight_params = "ffrom=#{origin.upcase}&fto=#{destination.upcase}&datefrom=#{shamsi_date}&adult=1&child=0&infant=0"
      url = @search_flight_url+search_flight_params
      data = URI.parse("#{url}").read
    rescue
      raise "Time out for zoraq" 
    end

    request_id = JSON.parse(data)["RequestId"]
    get_flight_params = "id=#{request_id}&last=0&ffrom=#{origin}&fto=#{destination}&datefrom=#{shamsi_date}&count=1&interval=1&isReturn=false&isNew=true"
    url = @get_flight_url+get_flight_params
    puts url
    response = URI.parse("#{url}").read
  end
end
