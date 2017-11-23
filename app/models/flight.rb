class Flight < ApplicationRecord
	validates :flight_number, :uniqueness => { :scope => :departure_time,
    :message => "already saved" }
  validates :route_id, presence: true
  belongs_to :route
  has_many :flight_prices
  has_one :flight_info

  attr_accessor :delay
  attr_accessor :suppliers_count
  attr_accessor :airline_persian_name
  attr_accessor :airline_english_name
  attr_accessor :airline_rate_average

  def self.create_or_find_flight(route_id,flight_number,departure_time,airline_code,airplane_type, arrival_date_time = nil ,stops = nil,trip_duration = nil)
    ActiveRecord::Base.connection_pool.with_connection do 
      is_flight_exist = Flight.find_by(route_id: route_id,flight_number:flight_number,departure_time:departure_time)
      if is_flight_exist.nil?
        begin
          #stored_flight = Flight.create(route_id: "#{route_id}", flight_number:"#{flight_number}", departure_time:"#{departure_time}",arrival_date_time: "#{arrival_date_time}", airline_code:"#{airline_code}", airplane_type: "#{airplane_type}")
          stored_flight = Flight.create(route_id: route_id, flight_number: flight_number, departure_time: departure_time,arrival_date_time: arrival_date_time, airline_code: airline_code, airplane_type: airplane_type, stops: stops, trip_duration: trip_duration)
          flight_id = stored_flight.id
        rescue
          flight_id = Flight.find_by(flight_number:flight_number,departure_time:departure_time).id
        end
      else
        flight_id = is_flight_exist.id
      end
    end
  end

  def self.update_best_price(origin,destination,date) 
    route = Route.find_by(origin:"#{origin}",destination:"#{destination}")
    flights = route.flights.where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s)
    flights.each do |flight|
      stored_flight_prices = flight.flight_prices.select("price,supplier").order("price").first
        if stored_flight_prices.nil? 
          flight.best_price = 0 #means the flight is no longer available
        else
          flight.best_price = stored_flight_prices.price 
          flight.price_by = stored_flight_prices.supplier 
        end
        flight.save()
      end
  end

  def get_lowest_price_collection(origin,destination)
      route = Route.find_by(origin:origin, destination:destination)
      dates = {today: Date.today.to_s, tomorrow: (Date.today+1).to_s, dayaftertomorrow: (Date.today+2).to_s}
      prices = {today: '', tomorrow: '', dayaftertomorrow: ''}

      dates.each do |title,date|
        prices[title.to_sym] = get_lowest_price(route,date)
      end
      
      prices
  end

  def get_lowest_price_time_table(origin,destination,date)

      route = Route.find_by(origin:origin, destination:destination)
      if date.to_date == Date.today
        starting_date = date
      elsif date.to_date == (Date.today+1)
        starting_date = (date.to_date-1).to_s
      else
        starting_date = (date.to_date-2).to_s
      end
      
      prices = Hash.new()
      dates = [(starting_date.to_date).to_s, (starting_date.to_date+1).to_s, (starting_date.to_date+2).to_s, (starting_date.to_date+3).to_s, (starting_date.to_date+4).to_s]
      dates.each do |date|
        prices[date.to_sym] =  get_lowest_price(route,date)
      end
      prices

  end

  def get_lowest_price_for_month(origin,destination)
    duration = 21
    prices = Array.new
    route = Route.find_by(origin:origin, destination:destination)
    0.upto(duration) do |x|
      date = (Date.today+x).to_s
      amount = get_lowest_price(route,date)
      if amount
        amount = amount[:best_price]
      else
        amount = "-"
      end
      prices << {date.to_sym =>amount}
    end
    prices
  end

  def get_lowest_price(route,date)
    begin
      flight = route.flights.where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s).where.not(best_price:0).sort_by(&:best_price).first
     rescue
      flight = nil
     end 
      
  end

  def airline_call_sign(airline_code)
  airlines ={"W5"=>"IRM",
    "AK"=>"ATR", 
      "B9"=>"IRB", 
      "sepahan"=>"SON", 
      "hesa"=>"SON",  
      "I3"=>"TBZ", 
      "JI"=>"MRJ", 
      "IV"=>"CPN", 
      "NV"=>"IRG", 
      "SE"=>"IRZ", 
      "ZV"=>"IZG",
      "HH"=>"TBN",
      "QB"=>"QSM" ,
      "Y9"=>"KIS",
      "EP"=>"IRC",
      "IR"=>"IRA",
      "SR"=>"SHI"
    }
  airlines[airline_code].nil? ? airline_code : airlines[airline_code]
  end

  def flight_list(route,date)
    airline_list = Airline.list 
    flight_list = route.flights.where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s).where.not(best_price:0)
    flight_list.each do |flight|
      flight_info = FlightInfo.find_by(flight_id: flight.id) 
      flight.suppliers_count = flight.flight_prices.count
      flight.delay = flight_info.delay unless flight_info.nil?
      flight.airline_code = flight.airline_code.split(",")[0]
      unless airline_list[flight.airline_code.to_sym].nil? 
        flight.airline_english_name = airline_list[flight.airline_code.to_sym][:english_name]
        flight.airline_persian_name = airline_list[flight.airline_code.to_sym][:persian_name] 
        flight.airline_rate_average = airline_list[flight.airline_code.to_sym][:rate_average].nil? ? 0 : airline_list[flight.airline_code.to_sym][:rate_average]
      else
        flight.airline_english_name = flight.airline_code
        flight.airline_persian_name = flight.airline_code
        flight.airline_rate_average = 0 
      end

      if flight.airplane_type.blank?
         flight.airplane_type = flight_info.airplane unless flight_info.nil? 
      end
     end
    flight_list = flight_list.sort_by(&:best_price)
  end

  def get_call_sign(flight_number,airline_code)
    call_sign = flight_number.upcase.sub airline_code.upcase, airline_call_sign(airline_code)
  end

  

end