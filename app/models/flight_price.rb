class FlightPrice < ApplicationRecord
	validates :flight_id, :uniqueness => { :scope =>[:supplier,:flight_date]}
end
