require 'test_helper'

class RouteControllerTest < ActionDispatch::IntegrationTest
  def setup
    @route_controller = RouteController.new
  end

  test "should get route page" do
    get route_page_path(origin_name:  "tehran",destination_name: "shiraz")
    assert_response :success
  end

  test "route statistic" do
    origin_code = "thr"
    destination_code = "kih"
    date = Date.today.to_s
    stats = RouteController.new
    response = stats.send(:route_statistic,origin_code,destination_code,date)  

    assert response[:date] == date
  end

  test "check month" do
    assert_equal  @route_controller.send(:check_month,"wrong"), false
    assert_equal  @route_controller.send(:check_month,"tir"), true
    assert_equal  @route_controller.send(:check_month,nil), false
  end

  test "get start date" do
    assert_equal  @route_controller.send(:get_start_date,"khordad"), "2019-05-22".to_date
  end

  test "create city page controoler obkect" do
    RouteController.new
  end

end
