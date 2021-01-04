# frozen_string_literal: true

require 'test_helper'

class SuppliersGhasedakTest < ActiveSupport::TestCase
  def setup
    @supplier = create_supplier(
      supplier: Suppliers::Ghasedak
    )
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
