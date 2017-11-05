class Airports::DomesticAirport
  
  def import(city_name,city_code)
    response = search(city_name)
    response = Nokogiri::HTML(response)
    import_departure_domestic_flights(response,city_code)
    import_arrival_domestic_flights(response,city_code)
  end

  def self.airports
    [
      ["mashhad","mhd",346],
      ["tabriz","tbz",81],
      ["shiraz","syz",181],
      ["ahwaz","awz",96],
      ["isfahan","ifn",108],
      ["kerman","ker",26],
      ["sari","sry",8],
      ["rasht","ras",14],
      ["yazd","azd",38],
      ["kermanshah","ksh",13],
      ["bandarabbas","bnd",23],
      ["zahedan","zah",22],
      ["bushehr","buz",29],
      ["gorgan","gbt",22],
      ["ardabil","adu",16]
    ]
  end
  
  def self.unnormal_airport 
    [["mehrabad","thr","Airports::Mehrabad"],["abadan","abd","Airports::Abadan"]]
  end
  

  def search(city_name)
    get_flight_url = "https://#{city_name}.airport.ir/flight-info"
  
    begin
      if Rails.env.test?
        response = File.read("test/fixtures/files/#{city_name}.log") 
      else
        #response = RestClient.get("#{URI.parse(get_flight_url)}")
        response = RestClient::Request.execute(:url => "#{URI.parse(get_flight_url)}", :method => :get, :verify_ssl => false)
        
    end
    rescue
      return false
    end
    return response
  end

  def import_departure_domestic_flights(response,city_code)
    origin = city_code
    doc = response.xpath('//*[@id="dep-flights-info"]/tbody/tr')

    doc.each do |flight|

      destination_name_in_persian = flight.css(".cell-dest p").text
      destination = City.get_city_code_based_on_name destination_name_in_persian

      next if destination == false #we dont want all cities

      route = Route.new.get_route(origin,destination)
      next if route.nil?
      call_sign = flight.css(".cell-fno p").text
      actual_departure_time = flight.css(".cell-airline p")[1].text
      status = flight.css(".cell-status p").text.tr("|","")
      airplane_type = flight.css(".cell-aircraft p").text
      departure_time = (flight.css(".cell-time p").text+(":00"))
      day = flight.css(".cell-day p").text
      day.strip!
      departure_date_time = get_date_time(day,departure_time)

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

  def import_arrival_domestic_flights(response,city_code)
    destination = city_code
    doc = response.xpath('//*[@id="arr-flights-info"]/tbody/tr')

    doc.each do |flight|

      origin_name_in_persian = flight.css(".cell-orig p").text
      origin = City.get_city_code_based_on_name origin_name_in_persian

      next if origin == false #we dont want all cities

      route = Route.new.get_route(origin,destination)
      next if route.nil?
      call_sign = flight.css(".cell-fno p").text
      actual_departure_time = flight.css(".cell-aircraft3 p").text
      status = flight.css(".cell-status p").text.tr("|","")
      airplane_type = flight.css(".cell-aircraft p").text
      departure_time = (flight.css(".cell-time p").text+(":00"))
      day = flight.css(".cell-day p").text
      day.strip!
      departure_date_time = get_date_time(day,departure_time)

      begin
        unless actual_departure_time.empty? 
          actual_departure_time = convert_to_gregorian actual_departure_time
        end
      rescue
      end

      FlightDetail.create(route_id: "#{route.id}",
        call_sign: "#{call_sign}",
        departure_time: "#{departure_date_time}",
        airplane_type: "#{airplane_type}",
        status: "#{status}",
        actual_departure_time:"#{actual_departure_time}")

    end
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

    yesterday_name = ((Time.now.to_date-1).strftime '%A').downcase
    today_name = (Time.now.to_date.strftime '%A').downcase
    tomorrow_name = ((Time.now.to_date+1).strftime '%A').downcase

    if get_english_name(day) == yesterday_name
      return yesterday_datetime.to_datetime
    elsif get_english_name(day) == today_name
      return today_datetime.to_datetime
    else
      return tomorrow_datetime.to_datetime
    end
  end

  def get_english_name day
    case day
	  when "شنبه"
	  	en_day_name = "saturday"
    when "یکشنبه", "یک شنبه", "یک‌شنبه"
	  	en_day_name = "sunday"
    when "دوشنبه", "دو شنبه"
	  	en_day_name = "monday"
    when  "سهشنبه", "سه شنبه", "سه‌شنبه"
	  	en_day_name = "tuesday"
    when "چهارشنبه", "چهار شنبه"
	  	en_day_name = "wednesday"
    when "پنجشنبه", "پنج شنبه", "پنج‌شنبه"
	  	en_day_name = "thursday"
    when "جمعه"
	  	en_day_name = "friday"
    end
    return en_day_name
  end

 
  

end