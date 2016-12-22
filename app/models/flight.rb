class Flight < ApplicationRecord
	validates :flight_number, uniqueness: true
end
