# frozen_string_literal: true

require 'test_helper'

class StaticDataControllerTest < ActionDispatch::IntegrationTest
  test 'should get about us' do
    get us_path
    assert_response :success
  end
end
