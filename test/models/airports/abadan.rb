require 'test_helper'

class AirportsAbadanTest < ActiveSupport::TestCase
  def setup
    @airport = Airports::Abadan.new   
  end
    
  test "airport data should saved to flight details" do
    assert_difference 'FlightDetail.count',28 do
      @results = @airport.search("abadan")
      @airport.import_domestic_flights(@results,"abd")
    end   
  end
end