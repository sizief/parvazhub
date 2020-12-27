# frozen_string_literal: true

require 'test_helper'

class SuppliersSnapptripTest < ActiveSupport::TestCase
  def setup
    origin = 'thr'
    destination = 'mhd'
    date = '2021-01-01'
    supplier_name = 'snapptrip'
    route = Route.find_or_create_by(origin: origin, destination: destination)
    search_history = SearchHistory.create(supplier_name: supplier_name, route: route)
    @alibaba = Suppliers::Snapptrip.new(
      origin: origin,
      destination: destination,
      route: route,
      date: date,
      search_history: search_history,
      supplier_name: supplier_name
    )
  end

  test 'Save flights to database' do
    VCR.use_cassette('snapptrip') do
      assert_difference 'Flight.count', 18 do
        @alibaba.search
      end
    end
  end

  test 'Save flight prices to database' do
    VCR.use_cassette('snapptrip') do
      assert_difference 'FlightPrice.count', 18 do
        @alibaba.search
      end
    end
  end
end
