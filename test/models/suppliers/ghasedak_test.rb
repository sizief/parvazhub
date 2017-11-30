require 'test_helper'

class SuppliersGhasedakTest < ActiveSupport::TestCase

  def setup
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-12-20"
    @search_history_id= 1
    @route=Route.find_by(origin: @origin, destination: @destination)
    @search_flight_token = 1
    @supplier_name = "Ghasedak"
    @ghasedak_obj=Suppliers::Ghasedak.new(origin: @origin,
                              destination: @destination, 
                              route: @route, 
                              date: @date, 
                              search_history_id: @search_history_id, 
                              search_flight_token: @search_flight_token, 
                              supplier_name: @supplier_name)
  end
    

  test "Ghasdak search should return Hash" do
    response = @ghasedak_obj.search_supplier
    assert response.is_a? Hash
    assert response[:response].is_a? String
    assert_not response[:response].empty?
  end

  test "Ghasdak get_airline_code should return airline code" do
    mahan_code = @ghasedak_obj.get_airline_code("W5")
    caspian_code = @ghasedak_obj.get_airline_code("RV")
    unknown_code = @ghasedak_obj.get_airline_code("ali")
    assert_equal mahan_code,"W5"
    assert_equal caspian_code,"IV"
    assert_equal unknown_code,"ali"
  end

  test "Save flights to database" do
    response = @ghasedak_obj.search_supplier
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'Flight.count', 22 do
      @ghasedak_obj.import_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "Save flight prices to database" do
    response = @ghasedak_obj.search_supplier
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'FlightPrice.count', 22 do
      @ghasedak_obj.import_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

end