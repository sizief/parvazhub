require 'sidekiq-scheduler'

class MostSearchRouteWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true
 
  def perform
    MostSearchRoute.new.perform
  end

end