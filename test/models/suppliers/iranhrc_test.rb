require 'test_helper'

class SuppliersIranhrcTest < ActiveSupport::TestCase

  def setup
    @iranhrc_search = Suppliers::Iranhrc.new
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-08-20"
    @search_history_id = 1
  end
    
  test "iranhrc send request should return string" do
    date = @date+"T00:00:00.0Z"
    response = @iranhrc_search.send_request(@origin,@destination,date,@search_history_id,1)
    assert response.is_a? String
    assert_not response.empty?
  end

  test "iranhrc search should return Hash" do
    response = @iranhrc_search.search(@origin,@destination,@date,@search_history_id)
    assert response.is_a? Hash
    assert response[:response].is_a? Array
    assert_not response[:response].empty?
  end

  test "iranhrc get_airline_code should return airline code" do
    mahan_code = @iranhrc_search.get_airline_code("5a9b4784-ded0-4fc0-b479-9294d4e2c0c3")
    zagros_code = @iranhrc_search.get_airline_code("b76a53dd-661a-4329-adb5-15cd191e698a")
    unknown_code = @iranhrc_search.get_airline_code("ali")
    assert_equal mahan_code,"W5"
    assert_equal zagros_code,"ZV"
    assert_equal unknown_code,nil
  end

  test "city correction" do
    corrected_city = @iranhrc_search.city_name_correction("BANDARABBAS")
    assert_equal "Bandar%20%60Abbas",corrected_city
  end

  test "Save flights to database" do
    response = @iranhrc_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'Flight.count', 20 do
      @iranhrc_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "Save flight prices to database" do
    response = @iranhrc_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'FlightPrice.count', 20 do
      @iranhrc_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end


end