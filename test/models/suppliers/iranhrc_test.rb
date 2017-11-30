require 'test_helper'

class SuppliersIranhrcTest < ActiveSupport::TestCase

  def setup
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-12-20"
    @search_history_id= 1
    @route=Route.find_by(origin: @origin, destination: @destination)
    @search_flight_token = 1
    @supplier_name = "Iranhrc"
    @iranhrc_obj=Suppliers::Iranhrc.new(origin: @origin,
                              destination: @destination, 
                              route: @route, 
                              date: @date, 
                              search_history_id: @search_history_id, 
                              search_flight_token: @search_flight_token, 
                              supplier_name: @supplier_name)
  end
    
  test "iranhrc send request should return string" do
    date = @date+"T00:00:00.0Z"
    response = @iranhrc_obj.send_request(@origin,@destination,date,@search_history_id,1)
    assert response.is_a? String
    assert_not response.empty?
  end

  test "iranhrc search should return Hash" do
    response = @iranhrc_obj.search_supplier
    assert response.is_a? Hash
    assert response[:response].is_a? Array
    assert_not response[:response].empty?
  end

  test "iranhrc get_airline_code should return airline code" do
    mahan_code = @iranhrc_obj.get_airline_code("5a9b4784-ded0-4fc0-b479-9294d4e2c0c3")
    zagros_code = @iranhrc_obj.get_airline_code("b76a53dd-661a-4329-adb5-15cd191e698a")
    unknown_code = @iranhrc_obj.get_airline_code("ali")
    assert_equal mahan_code,"W5"
    assert_equal zagros_code,"ZV"
    assert_equal unknown_code,nil
  end

  test "city correction" do
    corrected_city = @iranhrc_obj.city_name_correction("BANDARABBAS")
    assert_equal "Bandar%20%60Abbas",corrected_city
  end

  test "Save flights to database" do
    response = @iranhrc_obj.search_supplier
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'Flight.count', 20 do
      @iranhrc_obj.import_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "Save flight prices to database" do
    response = @iranhrc_obj.search_supplier
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'FlightPrice.count', 20 do
      @iranhrc_obj.import_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end


end