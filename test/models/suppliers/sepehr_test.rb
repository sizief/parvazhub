require 'test_helper'

class SuppliersSepehrTest < ActiveSupport::TestCase
=begin

  def setup
    @sepehr_search = Suppliers::Sepehr.new
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-09-20"
    @search_history_id = 1
  end
    
  test "sepehr search should answered with hash response" do
    response = @sepehr_search.search(@origin,@destination,@date,@search_history_id)
    assert response.is_a? Hash
    assert_not response[:response].empty?
  end

  test "should return correct airline code" do
   mahan = @sepehr_search.get_airline_code("W5")
   caspian = @sepehr_search.get_airline_code("RV")
   assert_equal mahan,"W5"
   assert_equal caspian,"IV"
  end


  test "flights from sepehr should saved to flights table" do
    response = @sepehr_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin,destination:@destination)
    assert_difference 'Flight.count', 19 do
      @sepehr_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "flight prices from sepehr should saved" do
    response = @sepehr_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin,destination:@destination)
    assert_difference 'FlightPrice.count', 19 do
      @sepehr_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end
=end
end