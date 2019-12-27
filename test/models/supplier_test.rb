# frozen_string_literal: true

require 'test_helper'

class SupplierTest < ActiveSupport::TestCase
  def setup
    @supplier = Supplier.new
  end

  test 'should return all suppliers name' do
    supplier_list = Supplier.all
    assert supplier_list.size > 3
  end

  test 'should return true suppliers if asked' do
    supplier_list = Supplier.where(status: true)
    assert supplier_list.size == 3
  end

  test 'should get supplier farsi name' do
    farsi_name = @supplier.get_persian_name 'zoraq'
    not_found_farsi_name = @supplier.get_persian_name 'notfound'
    assert farsi_name == 'زورق'
    assert not_found_farsi_name == 'notfound'
  end

  test 'should get supplier logo' do
    logo_path = @supplier.get_logo 'zoraq'
    logo_url = 'https://parvazhub.com/static/suppliers/zoraq-logo.png'
    assert_equal logo_path, logo_url
  end
end
