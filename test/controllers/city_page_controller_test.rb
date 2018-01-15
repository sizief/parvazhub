require 'test_helper'

class CityPageControllerTest < ActionDispatch::IntegrationTest
  def setup
    @city_page_controller = CityPageController.new
  end

  test "should get route page" do
    get route_page_path(origin_name:  "tehran",destination_name: "shiraz")
    assert_response :success
  end

  test "route statistic" do
    origin_code = "thr"
    destination_code = "kih"
    date = Date.today.to_s
    stats = CityPageController.new
    response = stats.send(:route_statistic,origin_code,destination_code,date)  

    assert response[:date] == date
  end

  test "check month" do
    assert_equal  @city_page_controller.send(:check_month,"wrong"), false
    assert_equal  @city_page_controller.send(:check_month,"tir"), true
    assert_equal  @city_page_controller.send(:check_month,nil), false
  end

  test "get start date" do
    assert_equal  @city_page_controller.send(:get_start_date,"khordad"), "2018-05-22".to_date
  end

  test "create city page controoler obkect" do
    CityPageController.new
  end

end
