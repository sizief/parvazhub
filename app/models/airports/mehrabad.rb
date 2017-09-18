class Airports::Mehrabad < Airports::DomesticAirport
  require "open-uri"
  require "uri"

  def import_domestic_flights(response,city_code)
    flight_details = Array.new()
    origin = city_code
    doc = Nokogiri::HTML(response)
    doc = doc.xpath('//*[@id="dep-flights-info"]/tbody/tr')

    doc.each do |flight|
      destination_name_in_persian = flight.css(".cell-dest p").text
      destination = City.get_city_code_based_on_name destination_name_in_persian

      next if destination == false #we dont want all cities

      route = Route.find_by(origin:"#{origin}",destination:"#{destination}")
      call_sign = flight.css(".cell-fno p").text
      actual_departure_time = flight.css(".cell-dateTime2 p").text
      status = flight.css(".cell-status p").text
      terminal = flight.css(".terminal p").text
      airplane_type = flight.css(".cell-aircraft p").text
      departure_time = (flight.css(".cell-time p").text+(":00"))
      day = flight.css(".cell-day p").text
      departure_date_time = get_date_time(day,departure_time)
      #airline = flight.css(".cell-airline p").text

      unless actual_departure_time.empty? 
        actual_departure_time = convert_to_gregorian actual_departure_time
      end

      FlightDetail.create(route_id: "#{route.id}",
        call_sign: "#{call_sign}",
        departure_time: "#{departure_date_time}",
        airplane_type: "#{airplane_type}",
        status: "#{status}",
        terminal:"#{terminal}",
        actual_departure_time:"#{actual_departure_time}")

    end
  end
end