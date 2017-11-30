require 'test_helper'

class SuppliersFlightioTest < ActiveSupport::TestCase

  def setup
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-12-20"
    @search_history_id= 1
    @route=Route.find_by(origin: @origin, destination: @destination)
    @search_flight_token = 1
    @supplier_name = "Flightio"
    @flightio_obj=Suppliers::Flightio.new(origin: @origin,
                              destination: @destination, 
                              route: @route, 
                              date: @date, 
                              search_history_id: @search_history_id, 
                              search_flight_token: @search_flight_token, 
                              supplier_name: @supplier_name)

    Flight.create(route_id: "1", flight_number:"123", departure_time:"#{@date} 05:00:00", airline_code:"W5", airplane_type: "airbus")
    Flight.create(route_id: "1", flight_number:"123", departure_time:"#{@date} 13:00:00", airline_code:"W5", airplane_type: "airbus")
    Flight.create(route_id: "1", flight_number:"123", departure_time:"#{@date} 06:00:00", airline_code:"QB", airplane_type: "airbus")
  end

    
  test "Flightio search should answered with hash response" do
    response = @flightio_obj.search_supplier
    assert response.is_a? Hash
    assert_not response[:response].empty?
  end

  test "flight prices from Flightio should saved" do
    response = @flightio_obj.search_supplier
    route = Route.find_by(origin:@origin,destination:@destination)
    assert_difference 'FlightPrice.count', 0 do
      @flightio_obj.import_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

end