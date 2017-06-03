require 'test_helper'

class AirportsMashhadTest < ActiveSupport::TestCase

  def setup
    @airport = Airports::Mashhad.new
  end
    
  test "airport data should saved to flight details" do
    #the provided sample file has 144 record
    assert_difference 'FlightDetail.count',99 do
      @results = @airport.search
      @airport.import_domestic_flights @results
    end   
  end

end