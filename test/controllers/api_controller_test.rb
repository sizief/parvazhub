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
  
  test "flights with valid route" do
    get api_flights_path, params: {
                                   :origin_name => "tehran", 
                                   :destination_name => 'kish', 
                                   :date => Date.today.to_s
  }
    json_response = JSON.parse(response.body)
    assert_equal true, json_response["status"]
    assert_response :success
  end

  test "flights with invalid route" do
    get api_flights_path, params: {
                                   :origin_name => "tehran", 
                                   :destination_name => 'not_a_city', 
                                   :date => Date.today.to_s
  }
    json_response = JSON.parse(response.body)
    assert_equal false, json_response["status"]
    assert_response :success
  end

  test "suppliers with eligible Id" do
    get api_suppliers_path, params: {:id => 10}
    json_response = JSON.parse(response.body)
    assert_equal true, json_response["status"]
    assert_response :success
  end

  test "suppliers with invalid Id" do
    get api_suppliers_path, params: {:id => 1}
    json_response = JSON.parse(response.body)
    assert_equal false, json_response["status"]
    assert_response :success
  end
 
end
