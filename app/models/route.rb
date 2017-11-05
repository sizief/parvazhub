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
          route = Route.new(origin: origin, destination: destination)
          route.save
        end
      end
      
      return route
    end
end
