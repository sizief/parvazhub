require 'test_helper'

class SuppliersRespinaTest < ActiveSupport::TestCase
=begin

  def setup
    @respina_search = Suppliers::Respina.new
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-08-20"
    @search_history_id = 1
  end
    

  test "Respina search should return Hash" do
    response = @respina_search.search(@origin,@destination,@date,@search_history_id)
    assert response.is_a? Hash
    assert response[:response].is_a? String
    assert_not response[:response].empty?
  end

  test "Respina get_airline_code should return airline code" do
    mahan_code = @respina_search.get_airline_code("2")
    qeshm_code = @respina_search.get_airline_code("11")
    unknown_code = @respina_search.get_airline_code("ali")
    assert_equal mahan_code,"W5"
    assert_equal qeshm_code,"QB"
    assert_equal unknown_code,nil
  end

  test "Save flights to database" do
    response = @respina_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'Flight.count', 41 do
      @respina_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "Save flight prices to database" do
    response = @respina_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'FlightPrice.count', 41 do
      @respina_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end
=end
end