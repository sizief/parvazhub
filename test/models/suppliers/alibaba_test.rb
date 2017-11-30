require 'test_helper'

class SuppliersAlibabaTest < ActiveSupport::TestCase
=begin
  def setup
    @alibaba_search = Suppliers::Alibaba.new
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-06-20"
    @search_history_id = 1
  end
    
  test "Alibaba search should answered with hash response" do
    response = @alibaba_search.search(@origin,@destination,@date,@search_history_id)
    assert response.is_a? Hash
    assert_not response[:response].empty?
  end

  test "flights from alibaba should saved to flights table" do
    response = @alibaba_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin,destination:@destination)
    assert_difference 'Flight.count', 11 do
      @alibaba_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "flight prices from alibaba should saved" do
    response = @alibaba_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin,destination:@destination)
    assert_difference 'FlightPrice.count', 11 do
      @alibaba_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end
=end
end