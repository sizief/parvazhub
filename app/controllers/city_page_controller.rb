class CityPageController < ApplicationController

  def not_found
  	raise ActionController::RoutingError.new('Not Found')
  end

  def route
    @link_count = 0
    @prices = Hash.new
    if check_month params[:month]   
      month = params[:month]    
      start_date = get_start_date month
    else 
      month = nil
      start_date = Date.today
    end

    route = Route.new.get_route_by_english_name(params[:origin_name],params[:destination_name])
    not_found unless route

    @origin = City.find_by(city_code: route.origin)
    @destination = City.find_by(city_code: route.destination)
    @route_days = RouteDay.week_days(@origin.city_code,@destination.city_code)
    @prices = Flight.new.get_lowest_price_for_a_month(@origin.city_code,@destination.city_code,start_date)
    @today_statistic = route_statistic(@origin.city_code,@destination.city_code,Date.today.to_s)
    @tomorrow_statistic = route_statistic(@origin.city_code,@destination.city_code,(Date.today+1).to_s)
    @day_after_statistic = route_statistic(@origin.city_code,@destination.city_code,(Date.today+2).to_s)

    @prices_for_calendar = prepare_for_calendar_view @prices
  end

  def flight
    @routes = Route.all.order(:origin)
    @default_destination_city = City.default_destination_city
  end

  private

  def check_month month
    months = %w(farvardin ordibehesht khordad tir mordad shahrivar mehr aban azar day bahman esfand)
    if months.include? month
      return true
    else
      return false
    end
  end

  def get_start_date month
    months_start_date = {farvardin: "03-21", 
                          ordibehesht: "04-21",
                          khordad: "05-22",
                          tir: "06-22",
                          mordad: "07-22",
                          shahrivar: "08-23",
                          mehr: "09-23",
                          aban: "10-23",
                          azar: "11-22",
                          day: "12-22",
                          bahman: "01-21",
                          esfand: "02-20"}
    selected_date = months_start_date[month.to_sym]
    selected_date_this_year = (DateTime.now.year.to_s + "-" + selected_date).to_date
    if selected_date_this_year+30 < Date.today
      ((DateTime.now.year+1).to_s + "-" + selected_date).to_date
    else
      (DateTime.now.year.to_s + "-" + selected_date).to_date
    end
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

  def prepare_for_calendar_view prices 
    offset =0
    temp_prices = prices
    first_day = prices.first[:date].to_date
    last_day = prices.last[:date].to_date
    first_day_name = first_day.strftime "%A"
    case first_day_name
      when "Saturday"
        offset = 0
      when "Sunday"
        offset = 1
      when "Monday"
        offset = 2
      when "Tuesday"
        offset = 3
      when "Wednesday"
        offset = 4
      when "Thursday"
        offset = 5
      when "Friday"
        offset = 6
    end

    #Always start on Saturday
    0.upto(offset-1) do |i|
      temp_prices.unshift({date: (first_day-i-1).to_s, price: nil})
    end

    0.upto(27-prices.size) do |i|
      temp_prices << {date: (last_day+i+1).to_s, price: nil}
    end
    return temp_prices
  end


end
