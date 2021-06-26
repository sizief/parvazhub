# frozen_string_literal: true

class HomeController < ApplicationController
  layout 'home'

  def index
    @routes = []
    routes = MostSearchRoute.new.get ENV['FIRST_PAGE_OFFERS'].to_i
    routes.each do |route|
      route = Route.find(route[:route_id])
      next if route.international?
      @routes << { route: route, details: Route.route_detail(route) }
    rescue StandardError
    end
    @is_mobile = browser.device.mobile?
    @search_parameter = user_last_search_params
    @user_last_searches = last_searches_without_past_dates
    @user_last_searches_limit = 3
  end

  private

  def last_searches
    return [] if current_user.nil?
    return [] if current_user.user_search_histories.empty?

    routes = {}
    current_user
      .user_search_histories
      .order('created_at DESC')
      .limit(10)
      .each do |search_history|
        route_id = search_history.route_id
        date =  search_history.departure_time
        if routes[route_id.to_s.to_sym].nil?
          routes[route_id.to_s.to_sym] = [date]
        else
          unless routes[route_id.to_s.to_sym].include? date
            routes[route_id.to_s.to_sym] << date
          end
        end
      end
    routes.keys.map do |route|
      { route_id: route.to_s, dates: routes[route] }
    end
  end

  def last_searches_without_past_dates
    last_searches.each do |search|
      fileterd_dates = []
      search[:dates].each do |date|
        fileterd_dates << date if date.to_date > Date.today - 1
      end
      if fileterd_dates.empty?
        fileterd_dates << (Date.today + 1).to_s
      end # add one date at least
      search[:dates] = fileterd_dates
    end
  end

  def user_last_search_params
    if current_user.nil? || current_user.user_search_histories.empty?
      return default_params
    end

    user_search_params
  end

  def user_search_params
    last_search = current_user.user_search_histories.last
    search_params(
      City.find_by(city_code: last_search.route.origin),
      City.find_by(city_code: last_search.route.destination),
      last_search.departure_time
    )
  end

  def default_params
    search_params(
      City.find_by(city_code: 'thr'),
      City.find_by(city_code: 'mhd'),
      (Date.today + 1).to_s
    )
  end

  def search_params(origin, destination, date)
    {
      origin_english_name: origin.english_name,
      origin_persian_name: origin.persian_name,
      origin_code: origin.city_code,
      destination_english_name: destination.english_name,
      destination_persian_name: destination.persian_name,
      destination_code: destination.city_code,
      date: date
    }
  end
end
