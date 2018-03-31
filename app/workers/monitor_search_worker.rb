require 'sidekiq-scheduler'

class MonitorSearchWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true
 
  def perform
    Timeout.timeout(60) do
      send_user_stats
      check_suppliers
    end
  end
  
  private
  def send_user_stats
    search_history = SearchHistory.where(created_at: (Time.now - 1.hours)..Time.now).count
    user_search_history = UserSearchHistory.where(created_at: (Time.now - 1.hours)..Time.now).count
    user_flight_price_history = UserFlightPriceHistory.where(created_at: (Time.now - 1.hours)..Time.now).count
    redirect = Redirect.where(created_at: (Time.now - 1.hours)..Time.now).count  
    text = "#{user_search_history} | #{user_flight_price_history} | #{redirect} \n total: #{search_history} \n "
    text = "👉" + text if (search_history == 0 or user_search_history == 0)
    
    TelegramMonitoringWorker.perform_async(text)  
  end

  def check_suppliers
    failed_suppliers = Array.new
    search_history = SearchHistory.where(created_at: (Time.now - 1.hours)..Time.now)
    Supplier.new.get_active_suppliers.each do |supplier|
      supplier_search = search_history.where(supplier_name: supplier.name.downcase)
      unless supplier_search.count == 0 
        failure_percentage = supplier_search.where(successful: false).count*100/supplier_search.count
        failed_suppliers << "#{supplier.name.downcase}: #{failure_percentage}" if failure_percentage > 20
      end
    end

    unless failed_suppliers.empty? 
      text = "👉" + failed_suppliers.to_s
      TelegramMonitoringWorker.perform_async(text)  
    end
  end

end