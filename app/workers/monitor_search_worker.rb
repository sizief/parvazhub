# frozen_string_literal: true

require 'sidekiq-scheduler'

class MonitorSearchWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, backtrace: true

  def perform
    Timeout.timeout(60) do
      send_user_stats
      check_suppliers
    end
  end

  private

  def send_user_stats
    search_history = SearchHistory.where('created_at > ?', Date.today).count
    user_search_history = UserSearchHistory.where('created_at > ?', Date.today).count
    user_flight_price_history = UserFlightPriceHistory.where('created_at > ?', Date.today).count
    redirect = Redirect.where('created_at > ?', Date.today).count
    text = "#{user_search_history} | #{user_flight_price_history} | #{redirect} \n total: #{search_history} \n "
    text = '👉' + text if (search_history == 0) || (user_search_history == 0)

    TelegramMonitoringWorker.perform_async(text)
  end

  def check_suppliers
    failed_suppliers = []
    search_history = SearchHistory.where('created_at > ?', Date.today)
    Supplier.new.get_active_suppliers.each do |supplier|
      supplier_search = search_history.where(supplier_name: supplier.name.downcase)
      next if supplier_search.count == 0

      failure_percentage = supplier_search.where(successful: false).count * 100 / supplier_search.count
      if failure_percentage > 20
        failed_suppliers << "#{supplier.name.downcase}: #{failure_percentage}"
      end
    end

    unless failed_suppliers.empty?
      text = '👉' + failed_suppliers.to_s
      TelegramMonitoringWorker.perform_async(text)
    end
  end
end
