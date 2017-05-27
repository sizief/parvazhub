class FlightPrice < ApplicationRecord
	belongs_to :flight

	def self.delete_old_flight_prices(supplier,route_id,date)
    	flights = Flight.where(route_id: route_id).where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s)
    	flights.each do |flight|
      		flight.flight_prices.where(supplier: "#{supplier}").where(flight_date:"#{date}").delete_all
    	end
  	end

end
