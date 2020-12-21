# frozen_string_literal: true

require 'test_helper'

class SuppliersGhasedakTest < ActiveSupport::TestCase
  def setup
    @origin = 'thr'
    @destination = 'mhd'
    @date = '2021-01-01'
    @search_history_id = 1
    @route = Route.find_by(origin: @origin, destination: @destination)
    @search_flight_token = 1
    @supplier_name = 'Ghasedak'
    @ghasedak = Suppliers::Ghasedak.new(origin: @origin,
                                        destination: @destination,
                                        route: @route,
                                        date: @date,
                                        search_history_id: @search_history_id,
                                        search_flight_token: @search_flight_token,
                                        supplier_name: @supplier_name)
  end

  test 'Ghasdak get_airline_code should return airline code' do
    mahan_code = @ghasedak.get_airline_code('W5')
    caspian_code = @ghasedak.get_airline_code('RV')
    unknown_code = @ghasedak.get_airline_code('ali')
    assert_equal mahan_code, 'W5'
    assert_equal caspian_code, 'IV'
    assert_equal unknown_code, 'ali'
  end

  test 'Ghasdak search should return Hash' do
    VCR.use_cassette('ghasedak') do
      response = @ghasedak.search_supplier
      assert response.is_a? Hash
      assert response[:response].is_a? String
      assert_not response[:response].empty?
    end
  end

  test 'Save flights to database' do
    VCR.use_cassette('ghasedak') do
      response = @ghasedak.search_supplier
      assert_difference 'Flight.count', 18 do
        @ghasedak.import_flights(response)
      end
    end
  end

  test 'Save flight prices to database' do
    VCR.use_cassette('ghasedak') do
      response = @ghasedak.search_supplier
      assert_difference 'FlightPrice.count', 18 do
        @ghasedak.import_flights(response)
      end
    end
  end
end
