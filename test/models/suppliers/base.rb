require 'test_helper'

class SuppliersBaseTest < ActiveSupport::TestCase

  def setup
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-12-20"
    @search_history_id= 1
    @route=Route.find_by(origin: @origin, destination: @destination)
    @search_flight_token = 1
    @supplier_name = "Flightio"
    @base_obj=Suppliers::Base.new(origin: @origin,
                              destination: @destination, 
                              route: @route, 
                              date: @date, 
                              search_history_id: @search_history_id, 
                              search_flight_token: @search_flight_token, 
                              supplier_name: @supplier_name)
  end


  test "calculate stop overs" do
    arrivals = ["2017-11-19 18:00:00".to_datetime,"2017-11-19 20:00:00".to_datetime,"2017-11-19 23:00:00".to_datetime]
    departures = ["2017-11-19 14:00:00".to_datetime,"2017-11-19 19:00:00".to_datetime,"2017-11-19 22:00:00".to_datetime]
    
    assert_equal  @base_obj.calculate_stopover_duration(["2017-11-19 18:00:00".to_datetime],["2017-11-19 18:00:00".to_datetime]),0 
    assert_equal  @base_obj.calculate_stopover_duration(departures,arrivals),180
  end
end