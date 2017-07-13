require 'test_helper'

class SuppliersZoraqTest < ActiveSupport::TestCase

  def setup
    @zoraq_search = Suppliers::Zoraq.new
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-06-20"
    @search_history_id = 1
  end
    
  test "Zoraq search should answered with hash response" do
    response = @zoraq_search.search(@origin,@destination,@date,@search_history_id)
    assert response.is_a? Hash
    assert_not response[:response].empty?
  end

  test "flights from zoraq should saved to flights table" do
    response = @zoraq_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin,destination:@destination)
    assert_difference 'Flight.count', 7 do
      @zoraq_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "flight prices from zoraq should saved" do
    response = @zoraq_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin,destination:@destination)
    assert_difference 'FlightPrice.count', 7 do
      @zoraq_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

end