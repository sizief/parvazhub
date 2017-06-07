require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get city_page_path(city_name:  "kish")
    assert_response :success
  end

end
