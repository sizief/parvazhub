# frozen_string_literal: true

class Airports::Mehrabad < Airports::DomesticAirport
  require 'open-uri'
  require 'uri'

  def import(city_name, city_code)
    response = Airports::DomesticAirport.new.search(city_name)
    response = Nokogiri::HTML(response)
    import_departure_domestic_flights(response, city_code)
    import_arrival_domestic_flights(response, city_code)
  end

  def import_departure_domestic_flights(response, city_code)
    origin = city_code
    doc = response.xpath('//*[@id="dep-flights-info"]/tbody/tr')

    doc.each do |flight|
      destination_name_in_persian = flight.css('.cell-dest p').text
      destination = City.get_city_code_based_on_name destination_name_in_persian
      next if destination == false # we dont want all cities

      route = Route.new.get_route(origin, destination)
      next if route.nil?

      call_sign = flight.css('.cell-fno p').text
      actual_departure_time = flight.css('.cell-dateTime2 p').text
      status = flight.css('.cell-status p').text
      terminal = flight.css('.terminal p').text
      airplane_type = flight.css('.cell-aircraft p').text
      departure_time = (flight.css('.cell-time p').text + ':00')
      day = flight.css('.cell-day p').text
      departure_date_time = get_date_time(day, departure_time)
      # airline = flight.css(".cell-airline p").text

      unless actual_departure_time.empty?
        actual_departure_time = convert_to_gregorian actual_departure_time
      end

      begin
        FlightDetail.create(route_id: route.id.to_s,
                            call_sign: call_sign.to_s,
                            departure_time: departure_date_time.to_s,
                            airplane_type: airplane_type.to_s,
                            status: status.to_s,
                            terminal: terminal.to_s,
                            actual_departure_time: actual_departure_time.to_s)
      rescue StandardError
        raise "route is empty, origin:#{origin}, destination:#{destination}"
      end
    end
  end

  def import_arrival_domestic_flights(response, city_code)
    destination = city_code
    doc = response.xpath('//*[@id="arr-flights-info"]/tbody/tr')

    doc.each do |flight|
      origin_name_in_persian = flight.css('.cell-orig p').text
      origin = City.get_city_code_based_on_name origin_name_in_persian
      next if origin == false # we dont want all cities

      route = Route.new.get_route(origin, destination)
      next if route.nil?

      call_sign = flight.css('.cell-fno p').text
      status = flight.css('.cell-status p').text.tr('|', '')
      airplane_type = flight.css('.cell-aircraft p').text
      departure_time = (flight.css('.cell-time p').text + ':00')
      day = flight.css('.cell-day p').text
      day.strip!
      departure_date_time = get_date_time(day, departure_time)

      begin
        FlightDetail.create(route_id: route.id.to_s,
                            call_sign: call_sign.to_s,
                            departure_time: departure_date_time.to_s,
                            airplane_type: airplane_type.to_s,
                            status: status.to_s)
      rescue StandardError
        raise "route is empty, origin:#{origin}, destination:#{destination}"
      end
    end
  end
end
