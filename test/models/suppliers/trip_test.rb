require 'test_helper'

class SuppliersTripTest < ActiveSupport::TestCase

  def setup
    @trip_search = Suppliers::Trip.new
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-08-20"
    @search_history_id = 1
  end
    
  test "trip send request should return string" do
    response = @trip_search.send_request(@origin,@destination,@date,@search_history_id,10)
    assert response.is_a? String
    assert_not response.empty?
  end

  test "trip search should return Hash" do
    response = @trip_search.search(@origin,@destination,@date,@search_history_id)
    assert response.is_a? Hash
    assert response[:response].is_a? Array
    assert_not response[:response].empty?
  end

  test "Save flights to database" do
    response = @trip_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'Flight.count', 19 do
      @trip_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "Save flight prices to database" do
    response = @trip_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'FlightPrice.count', 19 do
      @trip_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

end