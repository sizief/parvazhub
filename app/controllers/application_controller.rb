class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :redirect_subdomain

  @suppliers = Supplier.where(status: true)

  
  def redirect_subdomain
    if request.host == 'www.parvazhub.com'
      redirect_to 'https://parvazhub.com' + request.fullpath, :status => 301
    end
  end

  def is_bot(user_agent_request)
    if user_agent_request.nil?
      return false 
    else
      return ["Googlebot","yandex","MJ12bot","Baiduspider","bingbot","Yahoo!","spbot","parsijoo","CloudFlare","SafeDNSBot","Dataprovider","beambot","BLEXBot","panscient","bot","netEstate","crawler","Crawler"].any? {|word| user_agent_request.include? word}
    end
  end

  def set_cookie user_id
    cookies.permanent.signed[:user_id] = user_id
  end

  def read_cookie 
    cookies.permanent.signed[:user_id]
  end

end
