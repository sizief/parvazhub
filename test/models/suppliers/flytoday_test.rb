# frozen_string_literal: true

require 'test_helper'

class SuppliersFlytodayTest < ActiveSupport::TestCase
  def setup
    @origin = 'thr'
    @destination = 'ist'
    @date = '2017-12-20'
    @search_history_id = 1
    @route = Route.find_by(origin: @origin, destination: @destination)
    @search_flight_token = 1
    @supplier_name = 'Flytoday'
    @flytoday_obj = Suppliers::Flytoday.new(origin: @origin,
                                            destination: @destination,
                                            route: @route,
                                            date: @date,
                                            search_history_id: @search_history_id,
                                            search_flight_token: @search_flight_token,
                                            supplier_name: @supplier_name)
  end

  test 'search supplier' do
    response = @flytoday_obj.search_supplier
    assert response.is_a? Hash
    assert_not response[:response].empty?
  end

  test 'get params' do
    response = @flytoday_obj.get_params
    assert response.is_a? Hash
  end

  test 'to minutes' do
    time1 = @flytoday_obj.to_minutes '03:30'
    time2 = @flytoday_obj.to_minutes '3:30'
    time3 = @flytoday_obj.to_minutes '3:00'
    time4 = @flytoday_obj.to_minutes '0:30'

    assert_equal time1, 210
    assert_equal time2, 210
    assert_equal time3, 180
    assert_equal time4, 30
  end

  test 'import flights' do
    response = @flytoday_obj.search_supplier
    assert_difference 'Flight.count', 267 do
      @flytoday_obj.import_flights(response, @route.id, @origin, @destination, @date, @search_history_id)
    end
  end

  test 'save flight prices' do
    response = @flytoday_obj.search_supplier
    assert_difference 'FlightPrice.count', 267 do
      @flytoday_obj.import_flights(response, @route.id, @origin, @destination, @date, @search_history_id)
    end
  end
end
