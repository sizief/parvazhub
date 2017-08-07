require 'test_helper'

class SuppliersGhasedakTest < ActiveSupport::TestCase

  def setup
    @ghasedak_search = Suppliers::Ghasedak.new
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-08-20"
    @search_history_id = 1
  end
    

  test "Ghasdak search should return Hash" do
    response = @ghasedak_search.search(@origin,@destination,@date,@search_history_id)
    assert response.is_a? Hash
    assert response[:response].is_a? String
    assert_not response[:response].empty?
  end

  test "Ghasdak get_airline_code should return airline code" do
    mahan_code = @ghasedak_search.get_airline_code("2")
    zagros_code = @ghasedak_search.get_airline_code("9")
    unknown_code = @ghasedak_search.get_airline_code("ali")
    assert_equal mahan_code,"W5"
    assert_equal zagros_code,"ZV"
    assert_equal unknown_code,nil
  end

  test "Save flights to database" do
    response = @ghasedak_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'Flight.count', 46 do
      @ghasedak_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "Save flight prices to database" do
    response = @ghasedak_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'FlightPrice.count', 46 do
      @ghasedak_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

end