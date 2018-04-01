=begin
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



iranian_airlines =[{code: "W5", persian_name: "ماهان", english_name:"mahan"},
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
  {code: "SR", persian_name: "سپهران", english_name:"sepehran"}]

  iranian_airlines.each do |airline|
    x = Airline.find_by(code: airline[:code], english_name: airline[:english_name])
    x.country_code = "IR"
    x.save
  end


City.create(english_name: "saint petersburg",persian_name: "سن‌پترزبورگ", country_code: "RU", city_code: "led", status: true)

Supplier.all.each do |supplier|
  job_allowed = (supplier.name == "flytoday")? false : true
  supplier.job_search_allowed = job_allowed
  supplier.save
end

=end
User.create(email: "bot@parvazhub.com")
User.create(email: "job@parvazhub.com")
User.create(email: "app@parvazhub.com")




