# frozen_string_literal: true

require 'test_helper'

class FlightResultTest < ActiveSupport::TestCase
  def setup
    @flight_result = FlightResult.new(Route.first, Date.today.to_s)
  end

  test 'get' do
    response = @flight_result.call
    assert response.is_a? Array
  end
end
