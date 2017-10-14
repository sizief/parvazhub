class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :redirect_subdomain
  
  def redirect_subdomain
    if request.host == 'www.parvazhub.com'
      redirect_to 'https://parvazhub.com' + request.fullpath, :status => 301
    end
  end

  def is_bot(request_user_agent)
    if request_user_agent.nil?
      return false 
    else
      return ["Googlebot","yandex","MJ12bot","Baiduspider","bingbot","Yahoo!","spbot","parsijoo","CloudFlare","SafeDNSBot","Dataprovider","beambot","BLEXBot","panscient","bot","netEstate","crawler","Crawler"].any? {|word| request_user_agent.include? word}
    end
  end

end
