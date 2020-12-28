# frozen_string_literal: true

require 'test_helper'

class SuppliersRespinaTest < ActiveSupport::TestCase
  def setup
    @supplier = create_supplier(
      supplier: Suppliers::Respina24
    )
  end

  test 'Save flights to database' do
    VCR.use_cassette('respina24') do
      assert_difference 'Flight.count', 17 do
        @supplier.search
      end
    end
  end

  test 'Save flight prices to database' do
    VCR.use_cassette('respina24') do
      assert_difference 'FlightPrice.count', 17 do
        @supplier.search
      end
    end
  end
end
