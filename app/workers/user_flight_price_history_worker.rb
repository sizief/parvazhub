require 'sidekiq-scheduler'

class UserFlightPriceHistoryWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true, :queue => 'critical'
 
  def perform(channel,text,flight_id)
    Timeout.timeout(60) do
     # telegram = Telegram::Monitoring.new
     # telegram.send({text:text})
      TelegramMonitoringWorker.perform_async(text)      
      UserFlightPriceHistory.create(flight_id: flight_id,channel: channel) 
    end
  end

end