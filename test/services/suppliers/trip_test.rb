# frozen_string_literal: true

require 'test_helper'

class SuppliersTripTest < ActiveSupport::TestCase
  def setup
    @supplier = create_supplier(
      supplier: Suppliers::Trip,
      date: '2021-01-20'
    )
  end

  test 'Save flights to database' do
    VCR.use_cassette('trip') do
      assert_difference 'Flight.count', 12 do
        @supplier.search
      end
    end
  end

  test 'Save flight prices to database' do
    VCR.use_cassette('trip') do
      assert_difference 'FlightPrice.count', 12 do
        @supplier.search
      end
    end
  end
end
