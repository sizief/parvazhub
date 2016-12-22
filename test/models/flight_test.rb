require 'test_helper'

class FlightTest < ActiveSupport::TestCase
  
	def setup
		@flight = Flight.new(route_id: "15",flight_number: "w5717", departure_time:"11:22:00", airline_code: "w5")
	end

  test "Flight number should be unique" do
  	@flight.save
  	@second_flight = Flight.new(route_id: "15",flight_number: "w5717", departure_time:"11:22:00", airline_code: "w5")
  	assert_not @second_flight.valid?
  end

end
