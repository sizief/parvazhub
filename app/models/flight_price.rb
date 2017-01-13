class FlightPrice < ApplicationRecord
	validates :flight_id, :uniqueness => { :scope =>[:supplier,:flight_date]}
	belongs_to :flight
end
