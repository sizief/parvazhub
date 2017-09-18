require 'test_helper'

class AirportsMehrabadTest < ActiveSupport::TestCase
  def setup
    @airport = Airports::Mehrabad.new   
  end
    
  test "airport data should saved to flight details" do
    assert_difference 'FlightDetail.count',279 do
      @results = @airport.search("mehrabad")
      @airport.import_domestic_flights(@results,"thr")
    end   
  end
end