class Airports::Mehrabad
  require "open-uri"
  require "uri"

  def search
    #response = File.read("log/supplier/2017-05-30 12:05:17 +0000.log")
    #response
#begin
    get_flight_url = "https://mehrabad.airport.ir/flight-info"
  
    begin
      response = RestClient.get("#{URI.parse(get_flight_url)}")
    rescue
      return false
    end
    return response
#end
  end

  def import_domestic_flights(response)
    flight_details = Array.new()
    origin = "thr"
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
      departure_time = (flight.css(".cell-time p").text+(":00")).to_time
      day = flight.css(".cell-day p").text
      departure_date_time = get_date_time(day,departure_time)
      
      #airline = flight.css(".cell-airline p").text

      unless actual_departure_time.empty? 
        actual_departure_time = convert_to_gregorian actual_departure_time
      end

      
      #flight_details << FlightDetail.new(route_id: "#{route.id}",
      FlightDetail.create(route_id: "#{route.id}",
        call_sign: "#{call_sign}",
        departure_time: "#{departure_date_time}",
        airplane_type: "#{airplane_type}",
        status: "#{status}",
        terminal:"#{terminal}",
        actual_departure_time:"#{actual_departure_time}")

    end
    #FlightDetail.import flight_details
  end

  def convert_to_gregorian shamsi_date
    date = Parsi::DateTime.parse shamsi_date
    date = date.to_gregorian.to_date.to_s
    date += " "+shamsi_date[11..-1]
    date.to_datetime
  end

  def get_date_time(day,time)
    yesterday_datetime = (Time.now.to_date-1).to_s + " #{time}"
    today_datetime = (Time.now.to_date).to_s + " #{time}"
    tomorrow_datetime = (Time.now.to_date+1).to_s + " #{time}"

    yesterday_name = (Time.now.to_date-1).to_parsi.strftime '%A'
    today_name = Time.now.to_date.to_parsi.strftime '%A'
    tomorrow_name = (Time.now.to_date+1).to_parsi.strftime '%A'

    if day == yesterday_name
      return yesterday_datetime.to_datetime
    elsif day == today_name
      return today_datetime.to_datetime
    else
      return tomorrow_datetime.to_datetime
    end
  end

end