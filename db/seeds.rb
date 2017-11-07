# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#supplier_list = [
#        {class: "Suppliers::Flightio",name: "flightio"},
#        {class: "Suppliers::Zoraq",name: "zoraq"},
#        {class: "Suppliers::Alibaba",name: "alibaba"},
#        {class: "Suppliers::Safarme",name: "safarme"}

#    ]

#supplier_list.each do |supplier|
#  Supplier.create(name: supplier[:name],class_name: supplier[:class],status: true)
#end
 

=begin
airline_list =[
  {code: "W5", persian_name: "ماهان", english_name:"mahan"},
  {code: "AK", persian_name: "اترک", english_name:"atrak"},
  {code: "B9", persian_name: "ایران‌ایر‌تور", english_name:"iran-air-tour"}  ,
  {code: "SEPAHAN", persian_name: "سپاهان", english_name:"sepahan"},
  {code: "HESA", persian_name: "هسا", english_name:"hesa"},
  {code: "I3", persian_name: "آتا", english_name:"ata"},
  {code: "JI", persian_name: "معراج", english_name:"meraj"},
  {code: "IV", persian_name: "کاسپین", english_name:"caspian"},
  {code: "NV", persian_name: "نفت", english_name:"naft"},
  {code: "SE", persian_name: "ساها", english_name:"saha"},
  {code: "ZV", persian_name: "زاگرس", english_name:"zagros"},
  {code: "HH", persian_name: "تابان", english_name:"taban"},
  {code: "QB", persian_name: "قشم‌ایر", english_name:"qeshm-air"},
  {code: "Y9", persian_name: "کیش‌ایر", english_name:"kish-air"},
  {code: "EP", persian_name: "آسمان", english_name:"aseman"},
  {code: "IR", persian_name: "ایران‌ایر", english_name:"iran-air"},
  {code: "SR", persian_name: "سپهران", english_name:"sepehran"}
]

airline_list.each do |airline|
  Airline.create(code: airline[:code], persian_name: airline[:persian_name],english_name: airline[:english_name])
end


require 'csv'    
csv_text = File.read("db/countries.csv")
csv = CSV.parse(csv_text, :headers => true)
csv.each do |x|
  Country.create(x.to_hash)
end




require 'csv'    
csv_text = File.read("db/airports.csv")
csv = CSV.parse(csv_text, :headers => true)
csv.each do |x|
  Airport.create(x.to_hash)
end
=end
require 'csv'    
csv_text = File.read("db/cities-with-farsi.csv")
csv = CSV.parse(csv_text, :headers => true)
csv.each do |x|
  City.create(x.to_hash)
end


