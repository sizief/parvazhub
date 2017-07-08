require 'sidekiq-scheduler'

class ProxyCheckWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true
 
  def perform
     worker = Proxy.new
     worker.clean_up
  end
end