# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'should get home' do
    get home_path
    assert_response :success
  end

  test 'create home object' do
    HomeController.new
  end
end
