# frozen_string_literal: true

require 'test_helper'

class SuppliersIranhrcTest < ActiveSupport::TestCase
  def setup
    @origin = 'thr'
    @destination = 'mhd'
    @date = '2017-12-20'
    @search_history_id = 1
    @route = Route.find_by(origin: @origin, destination: @destination)
    @search_flight_token = 1
    @supplier_name = 'Iranhrc'
    @iranhrc_obj = Suppliers::Iranhrc.new(origin: @origin,
                                          destination: @destination,
                                          route: @route,
                                          date: @date,
                                          search_history_id: @search_history_id,
                                          search_flight_token: @search_flight_token,
                                          supplier_name: @supplier_name)
  end

  test 'Iranhrc search should return Hash' do
    response = @iranhrc_obj.search_supplier
    assert response.is_a? Hash
    # assert_not response[:response].empty?
  end

  test 'Save flights to database' do
    response = @iranhrc_obj.search_supplier
    route = Route.find_by(origin: @origin, destination: @destination)
    assert_difference 'Flight.count', 41 do
      @iranhrc_obj.import_flights(response, route.id, @origin, @destination, @date, @search_history_id)
    end
  end

  test 'Save flight prices to database' do
    response = @iranhrc_obj.search_supplier
    route = Route.find_by(origin: @origin, destination: @destination)
    assert_difference 'FlightPrice.count', 41 do
      @iranhrc_obj.import_flights(response, route.id, @origin, @destination, @date, @search_history_id)
    end
  end

  test 'get airline code' do
    sepehran_code = @iranhrc_obj.get_airline_code('SPN')
    unknown_code = @iranhrc_obj.get_airline_code('ali')
    assert_equal sepehran_code, 'SR'
    assert_equal unknown_code, 'ali'
  end
end
