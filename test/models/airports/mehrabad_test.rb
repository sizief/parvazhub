require 'test_helper'

class AirportsMehrabadTest < ActiveSupport::TestCase
  def setup
    @airport = Airports::Mehrabad.new   
  end
    
  test "airport data should saved to flight details" do
    assert_difference 'FlightDetail.count',616 do
      #@results = @airport.search("mehrabad")
      @airport.import("mehrabad","thr")
    end   
  end
end