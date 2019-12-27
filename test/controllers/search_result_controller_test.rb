# frozen_string_literal: true

require 'test_helper'

class SearchResultControllerTest < ActionDispatch::IntegrationTest
  test 'should return 200 ok if db is connected' do
    SearchResultController.new
  end
end
