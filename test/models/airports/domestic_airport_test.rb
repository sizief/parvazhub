# frozen_string_literal: true

require 'test_helper'

class AirportsDomesticAirportTest < ActiveSupport::TestCase
  def setup
    @airport = Airports::DomesticAirport.new
  end

  test 'return gregorian datetime' do
    shamsi_date = '1396-10-20 10:10'
    gregorian_datetime = @airport.convert_to_gregorian shamsi_date
    assert (gregorian_datetime.is_a? DateTime), 'not a date time'
  end

  test 'should retrun date time' do
    assert @airport.get_date_time('جمعه', '05:00').is_a? DateTime
  end
end
