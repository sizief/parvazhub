module Admin::DashboardHelper
	def user_search_history(date, channel=nil)
		if channel.nil?
			user_search = UserSearchHistory.where(created_at: date.to_datetime.beginning_of_day..date.to_datetime.end_of_day)
		else
			user_search = UserSearchHistory.where(created_at: date.to_datetime.beginning_of_day..date.to_datetime.end_of_day).where(channel: channel)
		end				
		user_search.count	
	end

	def user_search_history_all(channel=nil)
		if channel.nil?
			user_search = UserSearchHistory.count
		else
			user_search = UserSearchHistory.where(channel: channel).count
		end			
	end

	def user_flight_price_history(date, channel=nil)
		if channel.nil?
			user_flight_price = UserFlightPriceHistory.where(created_at: date.to_datetime.beginning_of_day..date.to_datetime.end_of_day)
		else
			user_flight_price = UserFlightPriceHistory.where(created_at: date.to_datetime.beginning_of_day..date.to_datetime.end_of_day).where(channel: channel)
		end				
		user_flight_price.count	
	end

	def user_flight_price_history_all(channel=nil)
		if channel.nil?
			user_flight_price = UserFlightPriceHistory.count
		else
			user_flight_price = UserFlightPriceHistory.where(channel: channel).count
		end			
	end

	def redirect(date, channel=nil)
		count = 0
		application = ApplicationController.new
		if channel.nil?
			redirects = Redirect.where(created_at: date.to_datetime.beginning_of_day..date.to_datetime.end_of_day)
		else
			redirects = Redirect.where(created_at: date.to_datetime.beginning_of_day..date.to_datetime.end_of_day).where(channel: channel)
		end	
		redirects.each do |redirect|
			count +=1 unless application.is_bot(redirect.user_agent)
		end
		return count
	end

	def redirect_all(channel=nil)
	  if channel.nil?
		redirect = Redirect.all.count
	  else
		redirect = Redirect.where(channel: channel).count
	  end
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
