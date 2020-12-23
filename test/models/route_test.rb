# frozen_string_literal: true

require 'test_helper'

class RouteTest < ActiveSupport::TestCase
  def setup
    @route = Route.new(origin: 'ika', destination: 'dxb')
  end

  test 'return route if finded' do
    route = Route.find_by(origin: 'thr', destination: 'mhd')
    assert route.id.is_a? Integer
  end

  test 'should create route if city exists but route not available' do
    assert_not Route.new.get_route('thr', 'mhd').nil?
    assert Route.new.get_route('thr', 'ttt').nil?
    assert_not Route.new.get_route('thr', 'nyc').nil?
  end

  test 'get route by english name' do
    route = Route.new.get_route_by_english_name('tehran', 'mashhad')
    assert route.is_a? Route
  end

  test 'get route by english name should return nil for not exist cities' do
    route = Route.new.get_route_by_english_name('tehran', 'gholi')
    assert route.nil?
  end
end
