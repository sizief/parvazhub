require 'test_helper'

class SuppliersFlightioTest < ActiveSupport::TestCase

  def setup
    @flightio_search = Suppliers::Flightio.new
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-06-20"

    Flight.create(route_id: "1", flight_number:"123", departure_time:"#{@date} 05:00:00", airline_code:"W5", airplane_type: "airbus")
    Flight.create(route_id: "1", flight_number:"123", departure_time:"#{@date} 13:00:00", airline_code:"W5", airplane_type: "airbus")
    Flight.create(route_id: "1", flight_number:"123", departure_time:"#{@date} 06:00:00", airline_code:"QB", airplane_type: "airbus")


  end

    
  test "Flightio search should answered with hash response" do
    response = @flightio_search.search(@origin,@destination,@date)
    assert response.is_a? Hash
    assert_not response[:response].empty?
  end

  test "flight prices from Flightio should saved" do
    
    response = @flightio_search.search(@origin,@destination,@date)
    route = Route.find_by(origin:@origin,destination:@destination)
    assert_difference 'FlightPrice.count', 3 do
      @flightio_search.import_domestic_flights(response,route.id,@origin,@destination,@date)
    end
  end

end