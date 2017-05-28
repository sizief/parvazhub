class Admin::DashboardController < ApplicationController
  def user_search_history
  	@ush = UserSearchHistory.last(500)
  end

  def search_history
  	@sh = SearchHistory.last(300)
  end
end
