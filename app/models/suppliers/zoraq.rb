class Suppliers::Zoraq
@url = "http://zoraq.com/Flight/DeepLinkSearch"

  def self.search(origin,destination,date)
  	require "uri"
  	require "net/http"
    begin
  	   params = {'OrginLocationIata' => "#{origin.upcase}", 'DestLocationIata' => "#{destination.upcase}", 'DepartureGo' => "#{date}", 'Passengers[0].Type' =>'ADT', 'Passengers[0].Quantity'=>'1'}
  	   x = Net::HTTP.post_form(URI.parse(@url), params)
  	   x.body
    rescue
      raise "Time out for zoraq" 
    end
  end
end