require 'test_helper'

class RouteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
  	@route = Route.new(origin: "ika", destination: "dxb")
  end
  

  test "return route if finded" do
    route = Route.find_by(origin:"thr",destination:"mhd")
    assert route.id.is_a? Integer
  end

  test "seed data loaded" do
    route = Route.find_by(origin: "ifn", destination: "thr")
    assert_not route.nil?
  end
   
  test "should create route if city exists but route not available" do
    available_city_1 = "thr"
    available_city_2 = "mhd"
    not_available_city = "trb"

    assert_not Route.new.get_route("thr","mhd").nil?
    assert Route.new.get_route("thr","ttt").nil?
    assert_not Route.new.get_route("thr","nyc").nil?
  end


  
end
