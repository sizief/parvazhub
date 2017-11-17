require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
   test "should return 200 ok if db is connected" do
    get service_test_path
    assert_response :success
   end
end
