# frozen_string_literal: true

require 'test_helper'

class FlightTest < ActiveSupport::TestCase
  def setup
    @route = Route.first
    @now = Time.now
    @flight = Flight.create(route: @route, flight_number: 'w57171', departure_time: @now, airline_code: 'w5')
  end

  test 'Flight number should be unique' do
    second_flight = Flight.create(route: @route, flight_number: 'w57171', departure_time: @now, airline_code: 'w5')
    assert_not second_flight.valid?
  end

  test 'airline_call_sign' do
    exist_airline_code = 'W5'
    non_exist_airline_code = 'TR'
    assert_equal Flight.new.airline_call_sign(exist_airline_code), 'IRM'
    assert_equal Flight.new.airline_call_sign(non_exist_airline_code), non_exist_airline_code
  end

  test 'flight list' do
    FlightPrice.create(flight: @flight, price: 100)
    flight_list = Flight.new.for(route: @route, date: @now.to_date.to_s)

    assert flight_list.count.positive?
  end

  test 'get_call_sign should return call sign' do
    flight_number = 'IR213'
    airline_code = 'IR'
    call_sign = Flight.new.get_call_sign(flight_number, airline_code)
    assert_equal call_sign, 'IRA213'
  end
end
