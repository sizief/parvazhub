# frozen_string_literal: true

require 'test_helper'

class RoutePageTest < ActionDispatch::IntegrationTest
  test 'browse existing route page' do
    get route_page_path(origin_name: 'tehran', destination_name: 'kish')
    assert_response :success
  end

  test 'browse not existing route page' do
    assert_raises(ActionController::RoutingError) do
      get route_page_path(origin_name: 'tehran', destination_name: 'notexist')
    end
  end

  test 'browse exist city but not exist route' do
    get route_page_path(origin_name: 'tehran', destination_name: 'edinburgh')
    assert_response :success
  end
end
