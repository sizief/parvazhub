# frozen_string_literal: true

require 'test_helper'

class SuppliersRespinaTest < ActiveSupport::TestCase
  include 'supplier_helper'

  def setup
    @supplier = create_supplier(
      supplier: Suppliers::Respina24
    )
  end

  test 'Save flights to database' do
    VCR.use_cassette('respina24') do
      assert_difference 'Flight.count', 14 do
        @supplier.search
      end
    end
  end

  test 'Save flight prices to database' do
    VCR.use_cassette('respina24') do
      assert_difference 'FlightPrice.count', 14 do
        @supplier.search
      end
    end
  end
end
