require 'test_helper'

class FlightPriceTest < ActiveSupport::TestCase
  def setup
  	@fp = FlightPrice.new(flight_id: "w5515", supplier: "zoraq", flight_date: DateTime.now.to_date)
  end
  
  test "should be valid" do
  	@fp.flight_date = "12-12-2016"
  	assert @fp.valid?
  end

  test "flight id and supplier and flight date should be unique" do
  	@fp.save
  	@fp2 = FlightPrice.new(flight_id: "w5515", supplier: "zoraq", flight_date: DateTime.now.to_date)
  	assert_not @fp2.valid?
  end

end
