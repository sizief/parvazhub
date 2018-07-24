require 'sidekiq-scheduler'

class UserSearchHistoryWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true, :queue => 'low'
 
  def perform(route_id,date,channel,user_id)
    Timeout.timeout(60) do
      UserSearchHistory.create(route_id:route_id,
                               departure_time:"#{date}",
                               channel:channel,
                               user_id: user_id) #save user search to show in admin panel      
    end
  end

end