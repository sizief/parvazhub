require 'sidekiq-scheduler'

class ProxyDeleteDeactivesWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true, :queue => 'low'
 
  def perform(ip,port)
      proxy = Proxy.find_by(ip:"#{ip}",port:"#{port}")
      unless proxy.nil?
        is_proxy_active = Proxy.new.check_validity(ip,port)
        proxy.delete unless is_proxy_active
      end
  end

 
end