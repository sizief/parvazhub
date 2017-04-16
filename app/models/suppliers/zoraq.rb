class Suppliers::Zoraq
    require "uri"
    require "rest-client"
    @url = "http://zoraq.com/Flight/DeepLinkSearch"

    def self.search(origin,destination,date)
      begin
  	   params = {'OrginLocationIata' => "#{origin.upcase}", 'DestLocationIata' => "#{destination.upcase}", 'DepartureGo' => "#{date}", 'Passengers[0].Type' =>'ADT', 'Passengers[0].Quantity'=>'1'}
       response = RestClient.post("#{URI.parse(@url)}", params)
       response.body
      rescue
      raise "Time out for zoraq" 
    end
  end
end