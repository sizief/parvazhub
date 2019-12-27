# frozen_string_literal: true

require 'test_helper'

class ReviewPageTest < ActionDispatch::IntegrationTest
  test 'browse airline review page' do
    get airline_review_index_page_path
    assert_response :success
  end

  test 'browse supplier index page' do
    get supplier_review_index_page_path
    assert_response :success
  end

  test 'browse supplier review page' do
    get supplier_review_page_path 'zoraq'
    assert_response :success
  end
end
