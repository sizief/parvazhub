class FlightPrice < ApplicationRecord
	#validates :flight_id, :uniqueness => { :scope =>[:supplier,:flight_date]}
	belongs_to :flight
	default_scope -> { order(price: :ASC) }

end
