# frozen_string_literal: true

require 'test_helper'

class SuppliersGhasedakTest < ActiveSupport::TestCase
  def setup
    origin = 'thr'
    destination = 'mhd'
    date = '2021-01-01'
    supplier_name = 'Ghasedak'
    route = Route.find_or_create_by(origin: origin, destination: destination)
    search_history = SearchHistory.create(supplier_name: supplier_name, route: route)
    @ghasedak = Suppliers::Ghasedak.new(
      origin: origin,
      destination: destination,
      route: route,
      date: date,
      search_history: search_history,
      supplier_name: supplier_name
    )
  end

  test 'Ghasdak get_airline_code should return airline code' do
    mahan_code = @ghasedak.get_airline_code('W5')
    caspian_code = @ghasedak.get_airline_code('RV')
    unknown_code = @ghasedak.get_airline_code('ali')
    assert_equal mahan_code, 'W5'
    assert_equal caspian_code, 'IV'
    assert_equal unknown_code, 'ali'
  end

  test 'Save flights to database' do
    VCR.use_cassette('ghasedak') do
      assert_difference 'Flight.count', 18 do
        @ghasedak.search
      end
    end
  end

  test 'Save flight prices to database' do
    VCR.use_cassette('ghasedak') do
      assert_difference 'FlightPrice.count', 18 do
        @ghasedak.search
      end
    end
  end
end
