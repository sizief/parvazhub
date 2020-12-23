# frozen_string_literal: true

require 'test_helper'

class SuppliersSafarestanTest < ActiveSupport::TestCase
  def setup
    origin = 'thr'
    destination = 'mhd'
    date = '2021-01-01'
    supplier_name = 'safarestan'
    route = Route.find_or_create_by(origin: origin, destination: destination)
    search_history = SearchHistory.create(supplier_name: supplier_name, route: route)
    search_flight_token = 1
    @safarestan = Suppliers::Safarestan.new(
      origin: origin,
      destination: destination,
      route: route,
      date: date,
      search_history_id: search_history.id,
      search_flight_token: search_flight_token,
      supplier_name: supplier_name
    )
  end

  test 'search supplier' do
    VCR.use_cassette('safarestan') do
      response = @safarestan.search_supplier
      assert response.is_a? Hash
      assert_not response[:response].empty?
    end
  end
end
