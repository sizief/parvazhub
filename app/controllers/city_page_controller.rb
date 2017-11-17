class CityPageController < ApplicationController
  include CityPageHelper

  def not_found
  	raise ActionController::RoutingError.new('Not Found')
  end

  def route
    @link_count = 0
    @prices = Hash.new
   
	  @origin = City.find_by(english_name:  params[:origin_name].downcase)   
    @destination = City.find_by(english_name: params[:destination_name].downcase)
    origin_city_code = @origin.nil? ? false : @origin.city_code
    destination_city_code = @destination.nil? ? false : @destination.city_code
    
    route = Route.new.get_route(origin_city_code,destination_city_code)
    not_found unless route
    

    @route_days = RouteDay.week_days(@origin.city_code,@destination.city_code)
    
    @prices[:to] = Flight.new.get_lowest_price_for_month(@origin.city_code,@destination.city_code)

    @today_statistic = route_statistic(@origin.city_code,@destination.city_code,Date.today.to_s)
    @tomorrow_statistic = route_statistic(@origin.city_code,@destination.city_code,(Date.today+1).to_s)
    @day_after_statistic = route_statistic(@origin.city_code,@destination.city_code,(Date.today+2).to_s)

    @prices = prepare_for_calendar_view @prices
  end

  def flight
    @routes = Route.all.order(:origin)
    @default_destination_city = City.default_destination_city
  end


  def route_statistic(origin_code,destination_code,date)
    response = Hash.new
    day_after = (date.to_date+1).to_s
    route=Route.find_by(origin: origin_code,destination: destination_code)
    flights = route.flights.where('departure_time >? and departure_time <?',date,day_after).order("departure_time")

    response[:date] = date
    response[:count] = flights.count
    unless flights.count == 0
      response[:first_flight_time] = flights.first.departure_time.strftime('%H:%M')
      response[:last_flight_time] = flights.last.departure_time.strftime('%H:%M')
    end

    return response
  end

end
