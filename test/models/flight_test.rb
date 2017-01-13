require 'test_helper'

class FlightTest < ActiveSupport::TestCase
  
	def setup
		@route = Route.first
		#@flight = Flight.new(route_id: "#{@route.id}",flight_number: "w5717", departure_time:"11:22:00", airline_code: "w5")
		@flight = @route.flights.build(flight_number: "w5717", departure_time:"11:22:00", airline_code: "w5")
	end

  test "Flight number should be unique" do
  	@flight.save
  	@second_flight = Flight.new(route_id: "15",flight_number: "w5717", departure_time:"11:22:00", airline_code: "w5")
  	assert_not @second_flight.valid?
  end

  test "route id should be exists" do
  	@flight.route_id = nil
  	assert_not @flight.save
  end

end
