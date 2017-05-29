class Admin::DashboardController < ApplicationController
  def user_search_history
  	@ush = UserSearchHistory.order(id: :desc).first(500)
  end

  def search_history
  	@sh = SearchHistory.order(id: :desc).first(300)
  end
end
