require 'test_helper'

class SupplierSearchTest < ActiveSupport::TestCase
  def setup
    origin = "thr"
    destination = "kih"
    date = Date.today.to_s
    timeout = ENV["TIMEOUT_DOMESTIC"]
    args = {origin: origin, destination: destination, date: date, timeout: timeout,search_initiator: "test"}
    @supplier_search = SupplierSearch.new(args)
  end

  test "number of flight shoudl change after search" do
    # how can test search in threads in test env?
    #assert_difference 'Flight.count',47 do #trip + zoraq
    #assert_difference 'Flight.count',31 do #trip 
    #    @supplier_search.search
    #end 
  end
end
