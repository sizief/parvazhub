class Flight < ApplicationRecord
	validates :flight_number, :uniqueness => { :scope => :departure_time,
    :message => "already saved" }
  validates :route_id, presence: true
  belongs_to :route
  has_many :flight_prices
	
  def self.flight_id(flight_number,departure_time)
    flight = Flight.select(:id).find_by(flight_number:"#{flight_number}", departure_time: "#{departure_time}")
    flight.id
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
      
      #dates = {first: (starting_date.to_date).to_s, second: (starting_date.to_date+1).to_s, third: (starting_date.to_date+2).to_s, fourth: (starting_date.to_date+3).to_s, fifth: (starting_date.to_date+4).to_s}
      #prices = {first:'', second:'',third:'', fourth: '', fifth: ''}

      #dates.each do |title,date|
      #    prices[title.to_sym] = get_lowest_price(route,date)
      #end
      #prices.reject{|price|}
      prices = Hash.new()
      dates = [(starting_date.to_date).to_s, (starting_date.to_date+1).to_s, (starting_date.to_date+2).to_s, (starting_date.to_date+3).to_s, (starting_date.to_date+4).to_s]
      dates.each do |date|
        prices[date.to_sym] =  get_lowest_price(route,date)
      end
      prices

  end

  def get_lowest_price(route,date)
      flight = route.flights.where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s).where.not(best_price:0).sort_by(&:best_price).first
      flight
  end

end
