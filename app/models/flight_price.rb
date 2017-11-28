class FlightPrice < ApplicationRecord
	belongs_to :flight, counter_cache: true

	def self.delete_old_flight_prices(supplier,route_id,date)
      flights = Flight.select(:id).where(route_id: route_id).where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s).to_a
	  flights = flights.map{ |flight| flight.id}
	  FlightPrice.where(flight_id: flights).where(flight_date:"#{date}").where(supplier: "#{supplier}").delete_all
	end 

end
