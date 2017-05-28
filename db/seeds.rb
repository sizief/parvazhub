# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

cities = City.list
cities.each do |origin_key,origin_value|
	cities.each do |destination_key,destination_value|
		Route.create(origin: origin_key, destination: destination_key) unless destination_key == origin_key
	end
end
