class Route < ApplicationRecord
	validates :origin, presence: true, :length => { :is => 3 }
	validates :destination, presence: true, :length => { :is => 3 }
	validates :origin, :uniqueness => { case_sensitive: false, :scope => :destination,
    :message => "already saved" }
  has_many :flights
  has_many :user_Search_history

    def get_route(origin,destination)
      route = Route.find_by(origin:"#{origin}",destination:"#{destination}")
      if route.nil?
        is_origin = City.find_by(city_code: origin)
        is_destination = City.find_by(city_code: destination)
        if (is_origin and is_destination)
          route = create_route(origin, destination)
          route.save
        end
      end
      
      return route
    end

    def get_route_by_english_name origin_name, destination_name
      origin_city_code = get_city_code_by_name origin_name
      destination_city_code = get_city_code_by_name destination_name
      Route.new.get_route(origin_city_code,destination_city_code)
    end
  
    private

    def get_city_code_by_name city_name
      city = City.find_by(english_name: city_name.downcase) 
      city_code = city.nil? ? false : city.city_code
    end

    def create_route(origin,destination)
      if ((City.find_by(city_code: origin).country_code=="IR") and 
        (City.find_by(city_code: destination).country_code=="IR"))
        international = false
      else
        international = true
      end
      Route.create(origin: origin, destination: destination, international: international)
    end

     
end
