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
    @user_last_searches = current_user.nil? ? [] : current_user.last_searches_without_past_dates
    @user_last_searches_limit = 3
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
