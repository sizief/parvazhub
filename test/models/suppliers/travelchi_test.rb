require 'test_helper'

class SuppliersTravelchiTest < ActiveSupport::TestCase
=begin

  def setup
    @travelchi_search = Suppliers::Travelchi.new
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-08-20"
    @search_history_id = 1
  end
    
  test "travelchi search should answered with hash response" do
    response = @travelchi_search.search(@origin,@destination,@date,@search_history_id)
    assert response.is_a? Hash
    assert_not response[:response].empty?
  end

  #test "get random key" do
  #  key = @travelchi_search.get_auth_key
  #  assert key.size == 216
  #end

  test "get price should return the number" do
    prices = [{"discounts"=>0.0, "fee"=>3000000.0, "flight_class"=>"Y", "remain"=>1, "status"=>"A"}]
    best_price= @travelchi_search.get_price prices
    assert best_price == 300000
  end

  test "flights from travelchi should saved to flights table" do
    response = @travelchi_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin,destination:@destination)
    assert_difference 'Flight.count', 15 do
      @travelchi_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "flight prices from travelchi should saved" do
    response = @travelchi_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin,destination:@destination)
    assert_difference 'FlightPrice.count', 15 do
      @travelchi_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end
=end
end