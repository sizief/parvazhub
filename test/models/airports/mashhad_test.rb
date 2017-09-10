require 'test_helper'

class AirportsMashhadTest < ActiveSupport::TestCase
=begin
  def setup
    @airport = Airports::Mashhad.new
  end
    
  test "airport data should saved to flight details" do
    #the provided sample file has 106 record
    assert_difference 'FlightDetail.count',135 do
      @results = @airport.search
      @airport.import_domestic_flights @results
    end   
  end
=end
end