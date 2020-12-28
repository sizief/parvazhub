# frozen_string_literal: true

require 'test_helper'

class SuppliersGhasedakTest < ActiveSupport::TestCase
  def setup
    @supplier = create_supplier(
      supplier: Suppliers::Ghasedak
    )
  end

  test 'Ghasdak get_airline_code should return airline code' do
    mahan_code = @supplier.get_airline_code('W5')
    caspian_code = @supplier.get_airline_code('RV')
    unknown_code = @supplier.get_airline_code('ali')
    assert_equal mahan_code, 'W5'
    assert_equal caspian_code, 'IV'
    assert_equal unknown_code, 'ali'
  end

  test 'Save flights to database' do
    VCR.use_cassette('ghasedak') do
      assert_difference 'Flight.count', 18 do
        @supplier.search
      end
    end
  end

  test 'Save flight prices to database' do
    VCR.use_cassette('ghasedak') do
      assert_difference 'FlightPrice.count', 18 do
        @supplier.search
      end
    end
  end
end
