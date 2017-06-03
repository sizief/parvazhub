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

  
end
