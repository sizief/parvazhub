class Route < ApplicationRecord
	validates :origin, presence: true, :length => { :is => 3 }
	validates :destination, presence: true, :length => { :is => 3 }
	validates :origin, :uniqueness => { case_sensitive: false, :scope => :destination,
    :message => "already saved" }
  has_many :flights
  has_many :user_Search_history

    #give the route id for given destination and origin
    def self.create_route(origin,destination)
       route = Route.find_by(origin:"#{origin}",destination:"#{destination}")
       if route.nil? #create this route if it is not exist is database
         route = Route.create(origin: origin.downcase, destination: destination.downcase)
       end
       route
    end
end
