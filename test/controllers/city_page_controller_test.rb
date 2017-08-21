require 'test_helper'

class CityPageControllerTest < ActionDispatch::IntegrationTest
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

end
