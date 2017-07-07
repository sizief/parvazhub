require 'sidekiq-scheduler'

class ProxyUpdateWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true
 
  def perform
     Proxy.import_list
  end
end