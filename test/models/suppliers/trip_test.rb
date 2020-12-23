# frozen_string_literal: true

require 'test_helper'

class SuppliersTripTest < ActiveSupport::TestCase
  def setup
    @origin = 'thr'
    @destination = 'mhd'
    @date = '2017-12-20'
    @route = Route.find_or_create_by(origin: @origin, destination: @destination)
    @supplier_name = 'Trip'
    @search_history = SearchHistory.create(supplier_name: @supplier_name, route: @route)
    @search_flight_token = 1
    @trip_obj = Suppliers::Trip.new(
      origin: @origin,
      destination: @destination,
      route: @route,
      date: @date,
      search_history_id: @search_history.id,
      search_flight_token: @search_flight_token,
      supplier_name: @supplier_name
    )
    @int_destination = 'ist'
    @params = {
      "src": @origin.upcase,
      "isCityCodeSrc": true,
      "dst": @destination.upcase,
      "isCityCodeDst": true,
      "class": 'e',
      "depDate": @date,
      "retDate": '',
      "adt": 1,
      "chd": 0,
      "inf": 0
    }
    @request_type = 'post'
  end

  test 'send request for register' do
    url = 'https://www.trip.ir/flex/search'
    response = @trip_obj.send_request(@request_type, url, @params)
    assert response.is_a? String
    assert_equal JSON.parse(response)['success'], true
  end

  test 'register request' do
    response = @trip_obj.register_request(@origin, @destination, @date)
    assert response.is_a? Hash
    assert response['sid'].is_a? String
  end

  test 'is search complete' do
    id = 1
    response = @trip_obj.is_search_complete(id)
    assert_equal response, true
  end

  test 'trip search should return Hash' do
    response = @trip_obj.search_supplier
    assert response.is_a? Hash
    assert_not response[:response].empty?
  end

  test 'Save flights to database' do
    response = @trip_obj.search_supplier
    assert_difference 'Flight.count', 47 do
      @trip_obj.import_flights(response)
    end
  end

  test 'Save international flights to database' do
    route = Route.find_or_create_by(origin: 'thr', destination: 'ist', international: true)
    response = Suppliers::Trip.new(
      origin: 'thr',
      destination: 'ist',
      route: route,
      date: @date,
      search_history_id: @search_history.id,
      search_flight_token: @search_flight_token,
      supplier_name: @supplier_name
    ).search_supplier
    assert_difference 'Flight.count', 127 do
      @trip_obj.import_flights(response)
    end
  end

  test 'Save flight prices to database' do
    response = @trip_obj.search_supplier
    assert_difference 'FlightPrice.count', 47 do
      @trip_obj.import_flights(response)
    end
  end

  test 'calculate stop overs' do
    arrivals = ['2017-11-19 18:00:00'.to_datetime, '2017-11-19 20:00:00'.to_datetime, '2017-11-19 23:00:00'.to_datetime]
    departures = ['2017-11-19 14:00:00'.to_datetime, '2017-11-19 19:00:00'.to_datetime, '2017-11-19 22:00:00'.to_datetime]

    assert_equal  @trip_obj.calculate_stopover_duration(['2017-11-19 18:00:00'.to_datetime], ['2017-11-19 18:00:00'.to_datetime]), 0
    assert_equal  @trip_obj.calculate_stopover_duration(departures, arrivals), 180
  end
end
