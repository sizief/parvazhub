# frozen_string_literal: true

class ApiController < ApplicationController
  after_action :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Max-Age'] = '1728000'
  end

  def city_prefetch_suggestion
    city_list = []
    country_list = Country.select(:country_code, :persian_name, :english_name).all.to_a
    cities = City.where('priority <?', 100).order('priority')

    cities.each do |city|
      country_object = country_list.detect { |c| c.country_code == city.country_code }
      country_value = country_object.persian_name.nil? ? country_object.english_name : country_object.persian_name
      city_list << { 'code': city.english_name,
                     'value': city.persian_name,
                     'country': country_value,
                     'en': english_result(city.english_name, country_object.english_name) }
    end
    render json: city_list
  end

  def city_suggestion
    query = params[:query].downcase
    city_list = []
    country_list = Country.select(:country_code, :persian_name, :english_name).all.to_a

    cities = City.where('english_name LIKE ? OR persian_name LIKE ?', "%#{query}%", "%#{query}%").order(:priority)
    cities.each do |city|
      persian_name = city.persian_name
      english_name = city.english_name
      country_object = country_list.detect { |c| c.country_code == city.country_code }

      city_value = city.persian_name.nil? ? english_name : persian_name
      country_value = country_object.persian_name.nil? ? country_object.english_name : country_object.persian_name
      city_list << { 'code': english_name,
                     'value': city_value,
                     'country': country_value,
                     'en': english_result(english_name, country_object.english_name) }
    end
    render json: city_list
  end

  def service_test
    sql = 'Select 1 from countries'
    status = ActiveRecord::Base.connection.execute(sql)
    if status
      render json: {
        status: 200
      }.to_json
    end
  end

  def flights
    channel = search_params[:channel].nil? ? 'android' : search_params[:channel]
    user_agent_request = channel
    date = search_params[:date]
    route = get_route search_params[:origin_name], search_params[:destination_name]

    if route && date_is_valid(date)
      body = get_flights(route, date, channel, user_agent_request)
      status = true
    else
      body = 'Aamoo ina chi chie mifresi? '
      unless date_is_valid(date)
        body += 'Date is invalid. Correct date format contract: 2017-01-01.'
        end
      unless route
        body += 'City codes are invalid. Correct origin and destination format contract: tehran or mashhad.'
        end
      status = false
    end
    render json: { status: status, search_params: api_search_params(route, date), body: body }
  end

  def suppliers
    channel = search_params[:channel].nil? ? 'android' : search_params[:channel]
    user_agent_request = channel
    flight = Flight.find_by_id(flight_price_params[:id])

    if flight
      body = get_flight_price(flight, channel, user_agent_request, current_user)
      status = true
    else
      body = 'Flight ID is invalid or out of date or sold out.' unless flight
      status = false
     end
    render json: { status: status, body: body }
  end

  private

  def english_result(city, country)
    { 'city': city.humanize, 'country': country.humanize }
  end

  def api_search_params(route, date)
    unless route.nil?
      origin = City.find_by(city_code: route.origin)
      destination = City.find_by(city_code: route.destination)
      {
        origin_persian_name: origin.persian_name,
        destination_persian_name: destination.persian_name,
        date: date
      }
    end
  end

  def get_flight_price(flight, channel, user_agent_request, user)
    FlightPriceController.new.get_flight_price(flight, channel, user_agent_request, user)
  end

  def date_is_valid(date)
    date_array = date.split('-').map(&:to_i)
    if Date.valid_date? date_array[0], date_array[1], date_array[2]
      true
    else
      false
    end
  rescue StandardError
  end

  def get_route(origin_name, destination_name)
    unless origin_name.nil? && destination_name.nil?
      route = Route.new.get_route_by_english_name(origin_name, destination_name)
    end
  end

  def get_flights(route, date, channel, user_agent_request)
    SearchResultController
      .new
      .flight_results(route, date, user_agent_request, current_user)
  end

  def search_params
    params.permit(:origin_name, :destination_name, :date, :channel)
  end

  def flight_price_params
    params.permit(:id)
  end
end
