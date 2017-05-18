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

end
