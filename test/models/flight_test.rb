require 'test_helper'

class FlightTest < ActiveSupport::TestCase
  
	def setup
		@route = Route.first
		#@flight = Flight.new(route_id: "#{@route.id}",flight_number: "w5717", departure_time:"11:22:00", airline_code: "w5")
		@flight = @route.flights.build(flight_number: "w57171", departure_time:"11:22:00", airline_code: "w5")
    @new_flight = Flight.new
    @date = Date.today.to_s
	end

  test "Flight number should be unique" do
  	@flight.save
  	#@second_flight = Flight.new(route_id: "15",flight_number: "w5717", departure_time:"11:22:00", airline_code: "w5")
    @second_flight = @route.flights.build(flight_number: "w57171", departure_time:"11:22:00", airline_code: "w5")
  	assert_not @second_flight.valid?
  end

  test "route id should be exists" do
  	@flight.route_id = nil
  	assert_not @flight.save
  end

  test "airline_call_sign" do
    exist_airline_code = "W5"
    non_exist_airline_code = "TR"
    assert_equal @new_flight.airline_call_sign(exist_airline_code), "IRM"
    assert_equal @new_flight.airline_call_sign(non_exist_airline_code), non_exist_airline_code
  end

  test "flight_list should be returned" do
    flight_list = @new_flight.flight_list(@route,@date)
    assert !!flight_list
    assert flight_list.is_a? Array
  end

  test "get_call_sign should return call sign" do
    flight_number = "IR213"
    airline_code = "IR"
    call_sign = @new_flight.get_call_sign(flight_number,airline_code)
    assert_equal call_sign,"IRA213"
  end
end
