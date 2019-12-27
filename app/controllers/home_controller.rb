# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    prepare_index current_user
  end

  def prepare_index(current_user)
    @routes = []
    routes = MostSearchRoute.new.get ENV['FIRST_PAGE_OFFERS'].to_i
    routes.each do |route|
      route = Route.find(route[:route_id])
      @routes << { route: route, details: Route.route_detail(route) }
    rescue StandardError
    end
    @is_mobile = browser.device.mobile?
    @search_parameter = user_last_search current_user
    @user_last_searches = current_user.nil? ? nil : current_user.last_searches_without_past_dates
    @user_last_searches_limit = 3
  end

  def user_last_search(user)
    params = if user.nil? || user.user_search_histories.empty?
               default_search_params
             else
               user_search_params user
             end
  end

  def user_search_params(user)
    origin = City.find_by(city_code: user.user_search_histories.last.route.origin)
    destination = City.find_by(city_code: user.user_search_histories.last.route.destination)
    date = user.user_search_histories.last.departure_time
    fill_params origin, destination, date
  end

  def default_search_params
    origin = City.find_by(city_code: 'thr')
    destination = City.find_by(city_code: 'mhd')
    date = (Date.today + 1).to_s
    { origin_english_name: origin.english_name,
      origin_code: origin.city_code,
      destination_english_name: destination.english_name,
      destination_code: destination.city_code,
      date: date }
  end

  def fill_params(origin, destination, date)
    { origin_english_name: origin.english_name,
      origin_persian_name: origin.persian_name,
      origin_code: origin.city_code,
      destination_english_name: destination.english_name,
      destination_persian_name: destination.persian_name,
      destination_code: destination.city_code,
      date: date }
  end
end
