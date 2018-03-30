require 'sidekiq-scheduler'

class SearchMonitorWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true
 
  def perform
    Timeout.timeout(60) do
      #search_history = SearchHistory.where(created_at: (Time.now - 1.hours)..Time.now).count
      user_search_history = UserSearchHistory.where(created_at: (Time.now - 1.hours)..Time.now).count
      user_flight_price_history = UserFlightPriceHistory.where(created_at: (Time.now - 1.hours)..Time.now).count
      redirect = Redirect.where(created_at: (Time.now - 1.hours)..Time.now).count
      text = "Search: #{user_search_history} \n Supplier Page: #{user_flight_price_history} \n Redirect: #{redirect} \n"
      text = "🔴" + text if (search_history == 0 or user_search_history == 0)
      TelegramMonitoringWorker.perform_async(text)  
    end
  end

end