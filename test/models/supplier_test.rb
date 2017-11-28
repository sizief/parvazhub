require 'test_helper'

class SupplierTest < ActiveSupport::TestCase

  test "should return all suppliers name" do
  	supplier_list = Supplier.all
  	assert supplier_list.size > 3
  end

  test "should return true suppliers if asked" do
    supplier_list = Supplier.where(status:true)
  	assert supplier_list.size == 2
  end
end
