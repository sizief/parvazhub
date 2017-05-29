require 'test_helper'

class StaticDataControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get static_pages_about_us_url
    assert_response :success
  end
end
