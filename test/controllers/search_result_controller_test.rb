# frozen_string_literal: true

require 'test_helper'

class SearchResultControllerTest < ActionDispatch::IntegrationTest
  test 'should get 200 ok' do
    get flight_result_path(origin_name: 'tehran', destination_name: 'shiraz', date: Date.today)
    assert_response :success
  end
end
