require 'sidekiq-scheduler'

class UserSearchHistoryWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true, :queue => 'low'
 
  def perform(text,route_id,date,channel)
    Timeout.timeout(60) do
      #TelegramMonitoringWorker.perform_async(text)   #send each search to telegram   
      UserSearchHistory.create(route_id:route_id,departure_time:"#{date}",channel:channel) #save user search to show in admin panel      
    end
  end

end