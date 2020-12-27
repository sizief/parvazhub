# frozen_string_literal: true

require 'test_helper'

class SearchFlightIdTest < ActiveSupport::TestCase
  def setup
    @token = 1
    SearchFlightId.create(token: @token, flight_ids: '[1, 2, 3, 4]')
    SearchFlightId.create(token: @token, flight_ids: '[5, 6, 7, 8]')
  end

  test 'ids should return flight ids' do
    assert SearchFlightId.ids(@token) == [1, 2, 3, 4, 5, 6, 7, 8]
  end
end
