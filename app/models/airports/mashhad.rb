class Airports::Mashhad < Airports::DomesticAirport
  require "open-uri"
  require "uri"

  def search
    get_flight_url = "https://mashhad.airport.ir/flight-info"
  
    begin
      if Rails.env.test?
        response = File.read("test/fixtures/files/mashhad.log") 
      else
        response = RestClient.get("#{URI.parse(get_flight_url)}")
    end
    rescue
      return false
    end
    return response
  end

  def import_domestic_flights(response)
    flight_details = Array.new()
    origin = "mhd"
    doc = Nokogiri::HTML(response)
    doc = doc.xpath('//*[@id="dep-flights-info"]/tbody/tr')

    doc.each do |flight|

      destination_name_in_persian = flight.css(".cell-dest p").text
      destination = City.get_city_code_based_on_name destination_name_in_persian

      next if destination == false #we dont want all cities

      route = Route.find_by(origin:"#{origin}",destination:"#{destination}")
      call_sign = flight.css(".cell-fno p").text
      actual_departure_time = flight.css(".cell-airline p")[1].text
      status = flight.css(".cell-status p").text.tr("|","")
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
        actual_departure_time:"#{actual_departure_time}")

    end
  end
end