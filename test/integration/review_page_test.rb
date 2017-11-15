require 'test_helper'

class ReviewPageTest < ActionDispatch::IntegrationTest
  test "browse review page" do
    get "/review"
    assert_response :success
  end
end
