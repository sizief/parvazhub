require 'test_helper'

class RedirectTest < ActiveSupport::TestCase
  
  test "should not save if flight price did not exist" do
  	redirect = Redirect.new
  	redirect.flight_price_id = 2
  	assert_difference 'Redirect.count', 0 do
      redirect.save
    end
  end

    test "should save if flight price exist" do
  	redirect = Redirect.new
  	flight_price = FlightPrice.last
  	redirect.flight_price_id = flight_price.id
  	assert_difference 'Redirect.count', 1 do
      redirect.save
    end
  end

end
