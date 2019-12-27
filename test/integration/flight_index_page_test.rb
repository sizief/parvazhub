# frozen_string_literal: true

require 'test_helper'

class FlightIndexPageTest < ActionDispatch::IntegrationTest
  test 'browse flight page' do
    get '/flights'
    assert_response :success
  end
end
