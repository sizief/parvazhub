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

end
