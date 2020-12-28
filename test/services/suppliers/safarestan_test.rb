# frozen_string_literal: true

require 'test_helper'

class SuppliersSafarestanTest < ActiveSupport::TestCase
  def setup
    @supplier = create_supplier(
      supplier: Suppliers::Safarestan
    )
  end

  test 'search supplier' do
    VCR.use_cassette('safarestan') do
      response = @supplier.search_supplier
      assert response.is_a? Hash
      assert_not response[:response].empty?
    end
  end
end
