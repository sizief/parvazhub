require 'test_helper'

class SuppliersTripTest < ActiveSupport::TestCase

  def setup
    @trip_search = Suppliers::Trip.new
    @origin = "thr"
    @destination = "mhd"
    @date = (Date.today+1).to_s
    @search_history_id = 1
    @int_destination = "ist"
    @params = {
      "src": @origin.upcase,		
      "isCityCodeSrc": true,	
      "dst": @destination.upcase,
      "isCityCodeDst": true,
      "class": "e",
      "depDate": @date,
      "retDate": "",
      "adt": 1,
      "chd": 0,
      "inf": 0
  }
    @request_type = "post"
    ENV["MAX_NUMBER_FLIGHT"] = "1000" #override default value which assigned in env file
  end
    
  test "send request for register" do
    url = "https://www.trip.ir/flex/search"
    response = @trip_search.send_request(@request_type,url,@params)
    assert response.is_a? String
    assert_equal JSON.parse(response)["success"], true
  end

  test "register request" do
    response = @trip_search.register_request(@origin,@destination,@date)
    assert response.is_a? Hash
    assert response["sid"].is_a? String
  end

  test "is search complete" do
    id = 1
    response = @trip_search.is_search_complete(id)
    assert_equal response, true
  end

  test "trip search should return Hash" do
    response = @trip_search.search(@origin,@destination,@date,@search_history_id)
    assert response.is_a? Hash
    assert_not response[:response].empty?
  end

  test "Save flights to database" do
    response = @trip_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'Flight.count', 47 do
      @trip_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "Save international flights to database" do
    response = @trip_search.search(@origin,@int_destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'Flight.count', 127 do
      @trip_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "Save international flight prices to database" do
    response = @trip_search.search(@origin,@int_destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'FlightPrice.count', 127 do
      @trip_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "Save flight prices to database" do
    response = @trip_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'FlightPrice.count', 47 do
      @trip_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "calculate stop overs" do
    arrivals = ["2017-11-19 18:00:00".to_datetime,"2017-11-19 20:00:00".to_datetime,"2017-11-19 23:00:00".to_datetime]
    departures = ["2017-11-19 14:00:00".to_datetime,"2017-11-19 19:00:00".to_datetime,"2017-11-19 22:00:00".to_datetime]
    
    assert_equal  @trip_search.calculate_stopover_duration(["2017-11-19 18:00:00".to_datetime],["2017-11-19 18:00:00".to_datetime]),0 
    assert_equal  @trip_search.calculate_stopover_duration(departures,arrivals),180

  end
end