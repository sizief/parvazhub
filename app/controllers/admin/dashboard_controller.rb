class Admin::DashboardController < ApplicationController
  def user_search_history
  	@ush = UserSearchHistory.all.order("created_at DESC")
  end
end
