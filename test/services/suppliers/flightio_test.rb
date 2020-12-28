# frozen_string_literal: true

require 'test_helper'

class SuppliersFlightioTest < ActiveSupport::TestCase
  def setup
    @supplier = create_supplier(
      supplier: Suppliers::Flightio
    )
  end

  test 'Save flights to database' do
    VCR.use_cassette('flightio') do
      assert_difference 'Flight.count', 17 do
        @supplier.search
      end
    end
  end

  test 'Save flight prices to database' do
    VCR.use_cassette('flightio') do
      assert_difference 'FlightPrice.count', 17 do
        @supplier.search
      end
    end
  end

  test 'does not raise error if register request is not a json' do
    route = Route.find_or_create_by(origin: 'thr', destination: 'mhd')
    flightio = Suppliers::Flightio.new(
      origin: route.origin,
      destination: route.destination,
      route: route,
      search_history: SearchHistory.create(supplier_name: 'ghasedak', route: route),
      date: nil, # this should cause an error
      supplier_name: 'ghasedak'
    )
    VCR.use_cassette('flightio-register-request') do
      response = flightio.search_supplier
      assert(response[:status] == false)
    end
  end
end
