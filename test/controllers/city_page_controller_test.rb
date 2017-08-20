require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get city_page_path(city_name:  "kish")
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

end
