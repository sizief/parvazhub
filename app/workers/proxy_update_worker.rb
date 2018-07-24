require 'sidekiq-scheduler'

class ProxyUpdateWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true, :queue => 'low'
 
  def perform
    Proxy.new.update_proxy
    check_validity
  end

  def check_validity
    Proxy.where(status:"active").each do |proxy|
      proxy.delete unless Proxy.new.check_validity(proxy.ip,proxy.port)
    end   
  end

end