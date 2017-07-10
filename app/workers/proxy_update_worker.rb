require 'sidekiq-scheduler'

class ProxyUpdateWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true, :queue => 'low'
 
  def perform
     worker = Proxy.new
     worker.update_proxy
  end
end