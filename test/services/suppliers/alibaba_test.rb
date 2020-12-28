# frozen_string_literal: true

require 'test_helper'

class SuppliersAlibabaTest < ActiveSupport::TestCase
  def setup
    @supplier = create_supplier(
      supplier: Suppliers::Alibaba
    )
  end

  test 'Save flights to database' do
    VCR.use_cassette('alibaba') do
      assert_difference 'Flight.count', 14 do
        @supplier.search
      end
    end
  end

  test 'Save flight prices to database' do
    VCR.use_cassette('alibaba') do
      assert_difference 'FlightPrice.count', 14 do
        @supplier.search
      end
    end
  end
end
