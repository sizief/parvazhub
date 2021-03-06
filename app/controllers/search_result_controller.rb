# frozen_string_literal: true

class SearchResultController < ApplicationController
  def flight_search
    origin = params[:search][:origin].downcase
    destination = params[:search][:destination].downcase
    date = params[:search][:date]

    redirect_to action: 'search', origin_name: origin, destination_name: destination, date: date
  end

  def search
    origin_name = params[:origin_name].downcase
    destination_name = params[:destination_name].downcase
    date = date_to_code params[:date]
    channel = 'website'
    route = Route.new.get_route_by_english_name(origin_name, destination_name)

    if date < Date.today.to_s
      redirect_to action: 'search', origin_name: origin_name, destination_name: destination_name, date: 'today'
      return
    end

    return notfound if route.nil?

    index(
      route,
      date,
      flight_results(route, date, request.user_agent)
    )
  end

  def notfound
    render :notfound
  end

  private

  def flight_results(route, date, user_agent)
    return  FlightResult.new(route, date).archive if is_bot(user_agent)
    
    save_search_history(route, date, 'website')
    date >= Date.today.to_s ? FlightResult.new(route, date).call : []
  end

  def index(route, date, flights)
    @flights = flights
    origin = City.find_by(city_code: route.origin)
    destination = City.find_by(city_code: route.destination)

    @search_parameter = search_parameters(origin, destination, date, route)
    @route_days = RouteDay.week_days(origin.city_code, destination.city_code)

    @flight_dates = Flight.new.get_lowest_price_timetable(
      origin.city_code,
      destination.city_code,
      date <= Date.today.to_s ? Date.today.to_s : date
    )
    @is_mobile = browser.device.mobile?
    @prices = Flight.new.get_lowest_price_for_a_week(origin.city_code, destination.city_code, Date.today)
    render :index
  end

  def search_parameters(origin, destination, date, route)
    {
      origin_english_name: origin.english_name,
      origin_persian_name: origin.persian_name,
      origin_code: origin.city_code,
      destination_english_name: destination.english_name,
      destination_persian_name: destination.persian_name,
      destination_code: destination.city_code,
      date: date,
      date_in_human: date_in_human(date),
      international: route.international
    }
  end

  def save_search_history(route, date, channel)
    return unless current_user

    UserSearchHistory.create(
      route_id: route.id,
      departure_time: date,
      channel: channel,
      user: current_user
    )
  end

  def date_in_human(date)
    date = date.to_date
    if date == Date.today
      'امروز'
    elsif date == (Date.today + 1)
      'فردا'
    else
      JalaliDate.new(date.to_date).strftime ' %d %b'
    end
  end

  def date_to_code(date)
    case date
    when 'today'
      Date.today.to_s
    when 'tomorrow'
      (Date.today + 1).to_s
    else
      date
    end
  end
end
