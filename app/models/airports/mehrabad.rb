class Airports::Mehrabad
  require "open-uri"
  require "uri"

  def search
    response = File.read("log/supplier/2017-05-30 12:05:17 +0000.log")
    response
=begin
    get_flight_url = "https://mehrabad.airport.ir/flight-info"
  
    begin
      response = RestClient.get("#{URI.parse(get_flight_url)}")
    rescue
      return false
    end
    return response
=end
  end


def import_domestic_flights(response)
      flight_prices = Array.new()
      doc = Nokogiri::HTML(response)
      doc = doc.xpath('//*[@id="dep-flights-info"]/tbody/tr')
      doc.each do |flight|
      debugger
      airline = flight.css(".cell-airline p").text
      flight_number = flight.css(".cell-fno p").text
      destination = flight.css(".cell-dest p").text
      status = flight.css(".cell-status p").text
      terminal = flight.css(".terminal p").text

      actual_departure_time = flight.css(".cell-dateTime2 p").text
      airplane = flight.css(".cell-aircraft p").text
      separture_time = flight.css(".cell-time p").text
      separture_date = flight.css(".cell-date p").text

=begin
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
      
      # first we should remove the old flight price archive 
      FlightPrice.delete_old_flight_prices("flightio",route_id,date) unless flight_prices.empty?
      # then bulk import enabled by a bulk import gem
      FlightPrice.import flight_prices 
      FlightPriceArchive.import flight_prices
=end
  end
  

end