class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :redirect_subdomain
  
  def redirect_subdomain
    if request.host == 'www.parvazhub.com'
      redirect_to 'https://parvazhub.com' + request.fullpath, :status => 301
    end
  end
end
