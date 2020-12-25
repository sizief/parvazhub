# frozen_string_literal: true

require 'test_helper'

class SuppliersAlibabaTest < ActiveSupport::TestCase
  def setup
    origin = 'thr'
    destination = 'mhd'
    date = '2021-01-01'
    supplier_name = 'Alibaba'
    route = Route.find_or_create_by(origin: origin, destination: destination)
    search_history = SearchHistory.create(supplier_name: supplier_name, route: route)
    search_flight_token = 1
    @alibaba = Suppliers::Alibaba.new(
      origin: origin,
      destination: destination,
      route: route,
      date: date,
      search_history_id: search_history.id,
      search_flight_token: search_flight_token,
      supplier_name: supplier_name
    )
  end

  test 'Alibaba search should return Hash' do
    VCR.use_cassette('alibaba') do
      response = @alibaba.search_supplier
      assert response.is_a? Hash
      assert response[:response].is_a? Array
    end
  end

  test 'Save flights to database' do
    VCR.use_cassette('alibaba') do
      response = @alibaba.search_supplier
      assert_difference 'Flight.count', 14 do
        @alibaba.import_flights(response)
      end
    end
  end

  test 'Save flight prices to database' do
    VCR.use_cassette('alibaba') do
      response = @alibaba.search_supplier
      assert_difference 'FlightPrice.count', 14 do
        @alibaba.import_flights(response)
      end
    end
  end
end
