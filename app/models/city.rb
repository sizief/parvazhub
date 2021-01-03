# frozen_string_literal: true

class City < ApplicationRecord
  validates :city_code, uniqueness: true
  validates :english_name, uniqueness: true

  def self.default_destination_city
    'kish'
  end

  def self.get_city_code_based_on_name(persian_name)
    persian_name = persian_name.sub 'ك', 'ک'
    persian_name = persian_name.sub 'ي', 'ی'

    city = City.find_by(persian_name: persian_name.strip)
    city.nil? ? false : city.city_code
  end

  def self.get_city_code_based_on_english_name(name)
    city = City.find_by(english_name: name)
    city.nil? ? false : city.city_code.downcase
  end

  def self.iran_cities_json_object
    City.where(country_code: 'IR').each_with_object({}) do |city, json_object|
      json_object[city.english_name.sub(' ', '_')] = city.persian_name.sub(' ', '')
    end
  end
end
