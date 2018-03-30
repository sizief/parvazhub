require 'sidekiq-scheduler'

class UserFlightPriceHistoryWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true, :queue => 'low'
 
  def perform(channel,text,flight_id)
    Timeout.timeout(60) do
      #TelegramMonitoringWorker.perform_async(text)  #send each flight details to telegram      
      UserFlightPriceHistory.create(flight_id: flight_id,channel: channel) 
    end
  end

end