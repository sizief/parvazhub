require 'test_helper'

class AirportsMehrabadTest < ActiveSupport::TestCase

  def setup
    @airport = Airports::Mehrabad.new
  end
    
  test "return gregorian datetime" do
    shamsi_date = "1396-10-20 10:10"
    gregorian_datetime = @airport.convert_to_gregorian shamsi_date
    assert (gregorian_datetime.is_a? DateTime), "not a date time"
  end

  #test "airport data should saved to flight details" do
  #  assert_no_difference 'FlightDetail.count', 'An Article should not be created' do
  #    @results = @airport.search
  #    @airport.import_domestic_flights @results
  #  end   
  #end

end
