require 'test_helper'

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  fixtures :all

  def setup
    sign_in users(:one)  
  end
  
  test "should get user_search_history" do
    @ush = UserSearchHistory.last
    get admin_user_search_histories_path
    assert_response :success
  end

end
