module Admin::DashboardHelper
	def user_search_hsitory date
      user_search = UserSearchHistory.where(created_at: date.to_datetime.beginning_of_day..date.to_datetime.end_of_day)
	  user_search.count
	end

	def user_search_hsitory_all
      user_search = UserSearchHistory.all
	  user_search.count
	end

	def redirect date
      redirect = Redirect.where(created_at: date.to_datetime.beginning_of_day..date.to_datetime.end_of_day)
	  redirect.count
	end

	def redirect_all
      redirect = Redirect.all
	  redirect.count
	end

	def notification date
      notification = Notification.where(created_at: date.to_datetime.beginning_of_day..date.to_datetime.end_of_day)
	  notification.count
	end

	def notification_all
      notification = Notification.all
	  notification.count
	end

	def search_history date
      search_history = SearchHistory.where(created_at: date.to_datetime.beginning_of_day..date.to_datetime.end_of_day)
	  search_history.count
	end

	def search_history_all
      search_history = SearchHistory.all
	  search_history.count
	end
end
