class Route < ApplicationRecord
	validates :origin, presence: true, :length => { :is => 3 }
	validates :destination, presence: true, :length => { :is => 3 }
	validates :origin, :uniqueness => { :scope => :destination,
    :message => "already saved" }

    #give the route id for given destination and origin
    def self.route_id(origin,destination)
       route = Route.select(:id).find_by(origin:"#{origin}",destination:"#{destination}")
       if route.nil? #create this route if it is not exist is database
         route = Route.create(origin: origin.downcase, destination: destination.downcase)
       end
       route.id
    end
end
