class HomeController < ApplicationController

  def index
    @routes = Array.new
    routes = MostSearchRoute.new.get 9 
    routes.each do |route|
      begin
        route = Route.find(route[:route_id])
        @routes << {route: route, details: Route.route_detail(route)}
      rescue
      end
    end
    @is_mobile = browser.device.mobile? 
  end

  def find_obj city_code
    City.find_by(city_code: city_code)
  end


end