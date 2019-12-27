# frozen_string_literal: true

class Route < ApplicationRecord
  validates :origin, presence: true, length: { is: 3 }
  validates :destination, presence: true, length: { is: 3 }
  validates :origin, uniqueness: { case_sensitive: false, scope: :destination,
                                   message: 'already saved' }
  has_many :flights
  has_many :user_Search_history
  has_many :most_search_routes

  def get_route(origin, destination)
    route = Route.find_by(origin: origin.to_s, destination: destination.to_s)
    if route.nil?
      is_origin = City.find_by(city_code: origin)
      is_destination = City.find_by(city_code: destination)
      if is_origin && is_destination
        route = create_route(origin, destination)
        route.save
      end
    end

    route
  end

  def get_route_by_english_name(origin_name, destination_name)
    origin_city_code = get_city_code_by_name origin_name
    destination_city_code = get_city_code_by_name destination_name
    Route.new.get_route(origin_city_code, destination_city_code)
  end

  def self.route_detail(route)
    origin = City.find_by(city_code: route.origin)
    destination = City.find_by(city_code: route.destination)
    {
      origin: { english_name: origin.english_name, persian_name: origin.persian_name },
      destination: { english_name: destination.english_name, persian_name: destination.persian_name }
    }
  end

  private

  def get_city_code_by_name(city_name)
    city = City.find_by(english_name: city_name.downcase)
    city_code = city.nil? ? false : city.city_code
  end

  def create_route(origin, destination)
    international = if (City.find_by(city_code: origin).country_code == 'IR') &&
                       (City.find_by(city_code: destination).country_code == 'IR')
                      false
                    else
                      true
                    end
    Route.create(origin: origin, destination: destination, international: international)
  end
end
