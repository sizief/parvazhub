require 'test_helper'

class RouteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
  	@route = Route.new(origin: "IKA", destination: "PAR")
  end
  
  test "should be valid" do
  	assert @route.valid?
  end

  test "origin and destination should NOT be empty" do
  	@route.origin = ""
  	@route.destination = ""
  	assert_not @route.valid?
  end

  test "origin and destinations should be unique" do
  	@route.origin = "thr"
  	@route.destination = "mhd"
  	assert_not @route.valid?
  end

  test "length should be 3" do
  	@route.origin = "a" * 4
  	assert_not @route.valid?
  end

  test "return the correct route id if exist" do
    route_id = Route.route_id(@route.origin.downcase,@route.destination.downcase)  
    assert route_id.is_a? Integer
  end

  test "create new route id if its not exists" do
    @route.origin = "par"
    @route.destination = "ika" 
    route_id = Route.route_id(@route.origin.downcase,@route.destination.downcase)  
    assert route_id.is_a? Integer
  end
end
