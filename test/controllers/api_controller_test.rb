require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
  test "should return 200 ok if db is connected" do
    get service_test_path
    assert_response :success
  end

  test "flights without params page test" do
    get api_flights_path 
    assert_response :success
  end

  test "flights" do
    get api_flights_path, params: {
                                   :origin_name => "tehran", 
                                   :destination_name => 'mashhad', 
                                   :date => Date.today.to_s
  }
    json_response = JSON.parse(response.body)
    assert_equal true, json_response["status"]
    assert_response :success
  end

  test "suppliers" do
    get api_suppliers_path, params: {
                                   :id => 1
  }
    json_response = JSON.parse(response.body)
    assert_equal false, json_response["status"]
    assert_response :success
  end
end
