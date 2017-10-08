require 'test_helper'

class AirportsDomesticAirportTest < ActiveSupport::TestCase

  def setup
    @airport = Airports::DomesticAirport.new
  end
    
  test "return gregorian datetime" do
    shamsi_date = "1396-10-20 10:10"
    gregorian_datetime = @airport.convert_to_gregorian shamsi_date
    assert (gregorian_datetime.is_a? DateTime), "not a date time"
  end

  test "should retrun date time" do
    assert @airport.get_date_time("جمعه","05:00").is_a? DateTime
  end

  test "get_english_name should return name day" do
    day = @airport.get_english_name "یک شنبه"
    assert day = "sunday"
  end


  test "Airports data should saved to flight details" do
    Airports::DomesticAirport.airports.each do |airport|
      assert_difference 'FlightDetail.count',airport[2] do
        @airport.import(airport[0],airport[1])
      end
    end   
  end

end