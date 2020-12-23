# frozen_string_literal: true

require 'test_helper'

class SuppliersSafarmeTest < ActiveSupport::TestCase
  def setup
    @origin = 'thr'
    @destination = 'mhd'
    date = '2017-12-20'
    supplier_name = 'Safarme'
    route = Route.find_or_create_by(origin: @origin, destination: @destination)
    search_history = SearchHistory.create(supplier_name: supplier_name, route: route)
    search_flight_token = 1
    @safarme = Suppliers::Safarme.new(
      origin: @origin,
      destination: @destination,
      route: route,
      date: date,
      search_history_id: search_history.id,
      search_flight_token: search_flight_token,
      supplier_name: supplier_name
    )
  end

  test 'Safarme search should return Hash' do
    response = @safarme.search_supplier
    assert response.is_a? Hash
    # assert_not response[:response].empty?
  end

  test 'Save flights to database' do
    response = @safarme.search_supplier
    assert_difference 'Flight.count', 38 do
      @safarme.import_flights(response)
    end
  end

  test 'Save flight prices to database' do
    response = @safarme.search_supplier
    assert_difference 'FlightPrice.count', 38 do
      @safarme.import_flights(response)
    end
  end

  test 'get airline code' do
    sepehran_code = @safarme.get_airline_code('SPN')
    unknown_code = @safarme.get_airline_code('ali')
    assert_equal sepehran_code, 'SR'
    assert_equal unknown_code, 'ali'
  end
end
