require 'test_helper'

class SuppliersSafarestanTest < ActiveSupport::TestCase

  def setup
    @origin = "thr"
    @destination = "mhd"
    @date = (Date.today+1).to_s
    @search_history_id= 1
    @route=Route.find_by(origin: @origin, destination: @destination)
    @search_flight_token = 1
    @supplier_name = "safarestan"
    @safarestan_obj=Suppliers::Safarestan.new(origin: @origin,
                              destination: @destination, 
                              route: @route, 
                              date: @date, 
                              search_history_id: @search_history_id, 
                              search_flight_token: @search_flight_token, 
                              supplier_name: @supplier_name)
  end
  
  test "search supplier" do
    response = @safarestan_obj.search_supplier
    assert response.is_a? Hash
    assert_not response[:response].empty?
  end

  test "get params" do
    response = @safarestan_obj.get_params
    assert response.is_a? Hash
  end

  

end