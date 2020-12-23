# frozen_string_literal: true

require 'test_helper'

class RouteDayTest < ActiveSupport::TestCase
  def setup
    @route_id = 1
    @route_day = RouteDay.new
  end

  test 'should import day - route' do
    days_available = [0, 5, 2, 4]
    assert_difference 'RouteDay.count', 4 do
      @route_day.import(days_available, @route_id)
    end

    not_available = []
    assert_difference 'RouteDay.count', 0 do
      @route_day.import(not_available, @route_id)
    end
  end

  test 'should not have duplicate day and route' do
    days_available = [0, 5, 2, 4]
    @route_day.import(days_available, @route_id)
    assert_difference 'RouteDay.count', 0 do
      @route_day.import(days_available, @route_id)
    end

    not_available = []
    assert_difference 'RouteDay.count', 0 do
      @route_day.import(not_available, @route_id)
    end
  end

  test 'should return days number arrays' do
    not_available = []

    assert_equal not_available, @route_day.inspect_days(10)
  end
end
