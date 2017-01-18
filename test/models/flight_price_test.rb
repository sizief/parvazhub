require 'test_helper'

class FlightPriceTest < ActiveSupport::TestCase
  def setup
  	flight = Flight.last
    @fp = flight.flight_price.build(supplier: "zoraq", flight_date: DateTime.now.to_date)
  end
  
  test "should be valid" do
  	#@fp.flight_date = "12-12-2016"
  	assert @fp.valid?
  end
=begin
  test "flight id and supplier and flight date should be unique" do
  	@fp.save
    @fp2 = flight.flight_price.build(supplier: "zoraq", flight_date: DateTime.now.to_date)
  	assert_not @fp2.valid?
  end
=end


end
