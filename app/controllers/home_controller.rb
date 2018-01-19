class HomeController < ApplicationController

  def index
    @routes = Array.new
    routes = MostSearchRoute.new.get ENV["FIRST_PAGE_OFFERS"].to_i 
    routes.each do |route|
      begin
        route = Route.find(route[:route_id])
        @routes << {route: route, details: Route.route_detail(route)}
      rescue
      end
    end
    @is_mobile = browser.device.mobile? 
  end

end