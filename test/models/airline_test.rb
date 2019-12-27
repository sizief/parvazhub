# frozen_string_literal: true

require 'test_helper'

class AirlineTest < ActiveSupport::TestCase
  test 'should get all airlines' do
    assert (Airline.list.is_a? Hash), 'not an array'
    assert (Airline.list.count > 200), 'less than 200'
  end
end
