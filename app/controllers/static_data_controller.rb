class StaticDataController < ApplicationController
	
	def self.import_route(origin,destination)
		Route.create(origin: origin.downcase, destination: destination.downcase)
	end

	def self.batch_import_route(arr = ["PAR","IST","DXB","HKT","AYT"])
 		arr.each do |iata_code|
 			import_route(iata_code,"IKA")
 		end
 	end
	
end
