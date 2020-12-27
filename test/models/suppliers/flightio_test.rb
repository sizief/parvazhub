# frozen_string_literal: true

require 'test_helper'

class SuppliersFlightioTest < ActiveSupport::TestCase
  def setup
    @origin = 'thr'
    @destination = 'mhd'
    @date = '2021-01-01'
    @supplier_name = 'Flightio'
    @route = Route.find_or_create_by(origin: @origin, destination: @destination)
    @search_history = SearchHistory.create(supplier_name: @supplier_name, route: @route)
    @search_flight_token = 1
    @flightio = Suppliers::Flightio.new(
      origin: @origin,
      destination: @destination,
      route: @route,
      date: @date,
      search_history: @search_history,
      supplier_name: @supplier_name
    )
  end

  test 'Save flights to database' do
    VCR.use_cassette('flightio') do
      assert_difference 'Flight.count', 17 do
        @flightio.search
      end
    end
  end

  test 'Save flight prices to database' do
    VCR.use_cassette('flightio') do
      assert_difference 'FlightPrice.count', 17 do
        @flightio.search
      end
    end
  end

  test 'does not raise error if register request is not a json' do
    flightio = Suppliers::Flightio.new(
      origin: @origin,
      destination: @destination,
      route: @route,
      date: nil, # this should cases an error
      search_history: @search_history,
      supplier_name: @supplier_name
    )
    VCR.use_cassette('flightio-register-request') do
      response = flightio.search_supplier
      assert(response[:status] == false)
    end
  end
end
