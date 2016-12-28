class StaticDataController < ApplicationController

	def self.batch_import_route(arr = ["PAR","IST","DXB","HKT","AYT"])
 		arr.each do |iata_code|
 			import_route(iata_code,"IKA")
 		end
 	end
	
end
