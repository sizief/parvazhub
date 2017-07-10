require 'sidekiq-scheduler'

class ProxyCheckAllWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true, :queue => 'low'
 
  def perform
    Proxy.where(status:"active").each do |proxy|
      ProxyDeleteDeactivesWorker.perform_async(proxy.ip,proxy.port)
    end
  end

end