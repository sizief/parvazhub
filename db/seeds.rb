#supplier_list = [
#        {class: "Suppliers::Flightio",name: "flightio"},
#        {class: "Suppliers::Zoraq",name: "zoraq"},
#        {class: "Suppliers::Alibaba",name: "alibaba"},
#        {class: "Suppliers::Safarme",name: "safarme"}

#    ]

#supplier_list.each do |supplier|
#  Supplier.create(name: supplier[:name],class_name: supplier[:class],status: true)
#end
 



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


require 'csv'    
csv_text = File.read("db/cities-with-farsi.csv")
csv = CSV.parse(csv_text, :headers => true)
csv.each do |x|
  City.create(x.to_hash)
end


require 'csv'    
csv_text = File.read("db/airlines.csv")
csv = CSV.parse(csv_text, :headers => true)
csv.each do |x|
  Airline.create(x.to_hash)
end

