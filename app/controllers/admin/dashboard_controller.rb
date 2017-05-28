class Admin::DashboardController < ApplicationController
  def user_search_history
  	@ush = UserSearchHistory.order(id: :desc).last(500)
  end

  def search_history
  	@sh = SearchHistory.order(id: :desc).last(300)
  end
end
