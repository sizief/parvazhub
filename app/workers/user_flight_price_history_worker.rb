require 'sidekiq-scheduler'

class UserFlightPriceHistoryWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true, :queue => 'low'
 
  def perform(channel,flight_id,user)
    Timeout.timeout(60) do
      UserFlightPriceHistory.create(flight_id: flight_id,channel: channel, user: user) 
    end
  end

end