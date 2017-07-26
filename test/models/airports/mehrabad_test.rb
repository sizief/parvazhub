require 'test_helper'

class AirportsMehrabadTest < ActiveSupport::TestCase

  def setup
    @airport = Airports::Mehrabad.new
  end
    
  test "airport data should saved to flight details" do
    #the provided sample file has 154 record
    assert_difference 'FlightDetail.count',189 do
      @results = @airport.search
      @airport.import_domestic_flights @results
    end   
  end

end