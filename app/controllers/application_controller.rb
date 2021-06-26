# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :redirect_subdomain
  before_action :set_current_user

  @suppliers = Supplier.where(status: true)

  def redirect_subdomain
    if request.host == 'www.parvazhub.com'
      redirect_to 'https://parvazhub.com' + request.fullpath, status: 301
    end
  end

  def is_bot(user_agent_request)
    if user_agent_request.nil?
      false
    else
      ['Googlebot', 'yandex', 'MJ12bot', 'Baiduspider', 'bingbot', 'Yahoo!', 'spbot', 'parsijoo', 'CloudFlare', 'SafeDNSBot', 'Dataprovider', 'beambot', 'BLEXBot', 'panscient', 'bot', 'netEstate', 'crawler', 'Crawler'].any? { |word| user_agent_request.include? word }
    end
  end

  def require_admin
    unless current_user && (current_user.role == 'admin')
      flash[:error] = 'You are not an admin'
      redirect_to root_path
    end
  end
  
  def current_user
    User.find(cookies.signed[:user_id])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def set_current_user
    @current_user ||= current_user
  end

  def authenticate_user
    render :file => "static_pages/401", :status => :unauthorized if !current_user
  end
end
