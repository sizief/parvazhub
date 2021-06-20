# frozen_string_literal: true

class ApiController < ApplicationController
  after_action :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
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

  private

  def english_result(city, country)
    { 'city': city.humanize, 'country': country.humanize }
  end
end
