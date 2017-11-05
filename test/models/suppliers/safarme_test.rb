require 'test_helper'

class SuppliersSafarmeTest < ActiveSupport::TestCase

  def setup
    @safarme_search = Suppliers::Safarme.new
    @origin = "thr"
    @destination = "mhd"
    @date = "2017-06-20"
    @search_history_id = 1
  end
    
  test "Safarme send request should return string" do
    sdate = (@date.to_datetime.to_s)[0..18]
    response = @safarme_search.send_request(@origin,@destination,sdate,@search_history_id,1)
    assert response.is_a? String
    assert_not response.empty?
  end

  test "Safarme search should return Hash" do
    response = @safarme_search.search(@origin,@destination,@date,@search_history_id)
    assert response.is_a? Hash
    assert response[:response].is_a? Array
    assert_not response[:response].empty?
  end

  test "Safarme get_airline_code should return airline code" do
    mahan_code = @safarme_search.get_airline_code("5a9b4784-ded0-4fc0-b479-9294d4e2c0c3")
    zagros_code = @safarme_search.get_airline_code("b76a53dd-661a-4329-adb5-15cd191e698a")
    unknown_code = @safarme_search.get_airline_code("ali")
    assert_equal mahan_code,"W5"
    assert_equal zagros_code,"ZV"
    assert_equal unknown_code,nil
  end

  test "Save flights to database" do
    response = @safarme_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'Flight.count', 30 do
      @safarme_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "Save flight prices to database" do
    response = @safarme_search.search(@origin,@destination,@date,@search_history_id)
    route = Route.find_by(origin:@origin, destination: @destination)
    assert_difference 'FlightPrice.count', 30 do
      @safarme_search.import_domestic_flights(response,route.id,@origin,@destination,@date,@search_history_id)
    end
  end

  test "test deeplink" do
    deeplink = @safarme_search.get_deep_link("thr","mhd","2018-01-10")
    date = "2018-01-10".to_date.to_parsi
    assert_equal deeplink,"http://safarme.com/flights/TEHRAN-to-MASHHAD/#{date}"  
  end

end