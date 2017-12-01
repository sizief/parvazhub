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
    response = stats.route_statistic(origin_code,destination_code,date)  

    assert response[:date] == date
  end

  test "check month" do
    assert_equal  @city_page_controller.check_month("wrong"), false
    assert_equal  @city_page_controller.check_month("tir"), true
    assert_equal  @city_page_controller.check_month(nil), false
  end

  test "get start date" do
    assert_equal  @city_page_controller.get_start_date("khordad"), "2018-05-22".to_date
  end

end
