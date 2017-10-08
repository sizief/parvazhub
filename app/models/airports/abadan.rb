class Airports::Abadan < Airports::DomesticAirport
    require "open-uri"
    require "uri"
    def import(city_name,city_code)
      response = Airports::DomesticAirport.new.search(city_name)
      response = Nokogiri::HTML(response)
      import_departure_domestic_flights(response,city_code)
      import_arrival_domestic_flights(response,city_code)
    end


    def import_departure_domestic_flights(response,city_code)
      origin = city_code
      doc = response.xpath('//*[@id="dep-flights-info"]/tbody/tr')
  
      doc.each do |flight|
        destination_name_in_persian = flight.css(".cell-orig p").text
        destination = City.get_city_code_based_on_name destination_name_in_persian
  
        next if destination == false #we dont want all cities
  
        route = Route.find_by(origin:"#{origin}",destination:"#{destination}")
        call_sign = flight.css(".cell-fno p").text
        status = flight.css(".cell-status p").text
        airplane_type = flight.css(".cell-aircraft p").text
        departure_time = (flight.css(".cell-time p").text+(":00"))
        day = flight.css(".cell-day p").text
        departure_date_time = get_date_time(day,departure_time)
  
        FlightDetail.create(route_id: "#{route.id}",
          call_sign: "#{call_sign}",
          departure_time: "#{departure_date_time}",
          airplane_type: "#{airplane_type}",
          status: "#{status}")  
      end
    end

    def import_arrival_domestic_flights(response,city_code)
      destination = city_code
      doc = response.xpath('//*[@id="arr-flights-info"]/tbody/tr')
  
      doc.each do |flight|
        origin_name_in_persian = flight.css(".cell-orig p").text
        origin = City.get_city_code_based_on_name origin_name_in_persian
        next if origin == false #we dont want all cities
  
        route = Route.find_by(origin:"#{origin}",destination:"#{destination}")
        call_sign = flight.css(".cell-fno p").text
        status = flight.css(".cell-status p").text.tr("|","")
        airplane_type = flight.css(".cell-aircraft p").text
        departure_time = (flight.css(".cell-time p").text+(":00"))
        day = flight.css(".cell-day p").text
        day.strip!
        departure_date_time = get_date_time(day,departure_time)
  
        FlightDetail.create(route_id: "#{route.id}",
          call_sign: "#{call_sign}",
          departure_time: "#{departure_date_time}",
          airplane_type: "#{airplane_type}",
          status: "#{status}")
  
      end
    end

  end