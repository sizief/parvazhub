# frozen_string_literal: true

require 'test_helper'

class SuppliersFlytodayTest < ActiveSupport::TestCase
  def setup
    origin = 'thr'
    destination = 'ist'
    date = '2017-12-20'
    supplier_name = 'Flytoday'
    route = Route.find_or_create_by(origin: origin, destination: destination, international: true)
    search_history = SearchHistory.create(supplier_name: supplier_name, route: route)
    search_flight_token = 1
    @flytoday = Suppliers::Flytoday.new(
      origin: origin,
      destination: destination,
      route: route,
      date: date,
      search_history_id: search_history.id,
      search_flight_token: search_flight_token,
      supplier_name: supplier_name
    )
  end

  test 'search supplier' do
    skip
    response = @flytoday.search_supplier
    assert response.is_a? Hash
    assert_not response[:response].empty?
  end

  test 'get params' do
    skip
    response = @flytoday.get_params
    assert response.is_a? Hash
  end

  test 'to minutes' do
    skip
    time1 = @flytoday.to_minutes '03:30'
    time2 = @flytoday.to_minutes '3:30'
    time3 = @flytoday.to_minutes '3:00'
    time4 = @flytoday.to_minutes '0:30'

    assert_equal time1, 210
    assert_equal time2, 210
    assert_equal time3, 180
    assert_equal time4, 30
  end

  test 'import flights' do
    skip
    response = @flytoday.search_supplier
    assert_difference 'Flight.count', 267 do
      @flytoday.import_flights(response)
    end
  end

  test 'save flight prices' do
    skip
    response = @flytoday.search_supplier
    assert_difference 'FlightPrice.count', 267 do
      @flytoday.import_flights(response)
    end
  end
end
