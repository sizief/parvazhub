# frozen_string_literal: true
supplier_list = [
  { "id": 7, "name": 'trip', "class_name": 'Suppliers::Trip', "status": false, "international": true, "domestic": true, "job_search_allowed": false, "rate_count": 0, "rate_average": 0 },
  { "id": 5, "name": 'ghasedak', "class_name": 'Suppliers::Ghasedak', "status": true, "international": false, "domestic": true, "job_search_allowed": false, "rate_count": 4, "rate_average": 3 },
  { "id": 11, "name": 'safarestan', "class_name": 'Suppliers::Safarestan', "status": true, "international": false, "domestic": true, "job_search_allowed": false, "rate_count": 4, "rate_average": 5 },
  { "id": 1, "name": 'flightio', "class_name": 'Suppliers::Flightio', "status": true, "international": false, "domestic": true, "job_search_allowed": false, "rate_count": 4, "rate_average": 5 },
  { "id": 3, "name": 'alibaba', "class_name": 'Suppliers::Alibaba', "status": false, "international": false, "domestic": true, "job_search_allowed": false, "rate_count": 0, "rate_average": 0 },
  { "id": 6, "name": 'respina', "class_name": 'Suppliers::Respina24', "status": false, "international": false, "domestic": true, "job_search_allowed": false, "rate_count": 0, "rate_average": 0 }
]

supplier_list.each do |supplier|
  Supplier.create(
    name: supplier[:name],
    class_name: supplier[:class_name],
    status: supplier[:status],
    international: supplier[:international],
    domestic: supplier[:domestic],
    job_search_allowed: supplier[:job_search_allowed],
    rate_count: supplier[:rate_count],
    rate_average: supplier[:rate_average])
end

require 'csv'
csv_text = File.read('db/countries.csv')
csv = CSV.parse(csv_text, headers: true)
csv.each do |x|
  Country.create(x.to_hash)
end

csv_text = File.read('db/airports.csv')
csv = CSV.parse(csv_text, headers: true)
csv.each do |x|
  Airport.create(x.to_hash)
end

csv_text = File.read('db/cities-with-farsi.csv')
csv = CSV.parse(csv_text, headers: true)
csv.each do |x|
  City.create(x.to_hash)
end

csv_text = File.read('db/airlines.csv')
csv = CSV.parse(csv_text, headers: true)
csv.each do |x|
  Airline.create(x.to_hash)
end
Airline.find_by(code: 'VA').delete
Airline.find_by(code: 'PY').delete
Airline.create(code: 'VA', persian_name: 'وارش', english_name: 'varesh', country_code: 'IR')
Airline.create(code: 'PY', persian_name: 'پویا', english_name: 'pouya', country_code: 'IR')
Airline.find_by(code: 'VR').update(persian_name: 'وارش', english_name: 'varesh', country_code: 'IR')
Airline.find_by(code: 'SA').update(persian_name: 'ساها', english_name: 'Saha', country_code: 'IR')
Airline.find_by(code: 'FP').update(persian_name: 'فلای پرشیا', english_name: 'Fly Persia', country_code: 'IR')

User.create(email: 'bot@parvazhub.com')
User.create(email: 'job@parvazhub.com')
User.create(email: 'app@parvazhub.com')

iranian_airlines = [{ code: 'W5', persian_name: 'ماهان', english_name: 'mahan' },
                    { code: 'AK', persian_name: 'اترک', english_name: 'atrak' },
                    { code: 'B9', persian_name: 'ایران‌ایر‌تور', english_name: 'iran-air-tour' },
                    { code: 'SEPAHAN', persian_name: 'سپاهان', english_name: 'sepahan' },
                    { code: 'HESA', persian_name: 'هسا', english_name: 'hesa' },
                    { code: 'I3', persian_name: 'آتا', english_name: 'ata' },
                    { code: 'JI', persian_name: 'معراج', english_name: 'meraj' },
                    { code: 'IV', persian_name: 'کاسپین', english_name: 'caspian' },
                    { code: 'NV', persian_name: 'نفت', english_name: 'naft' },
                    { code: 'SE', persian_name: 'ساها', english_name: 'saha' },
                    { code: 'ZV', persian_name: 'زاگرس', english_name: 'zagros' },
                    { code: 'HH', persian_name: 'تابان', english_name: 'taban' },
                    { code: 'QB', persian_name: 'قشم‌ایر', english_name: 'qeshm-air' },
                    { code: 'Y9', persian_name: 'کیش‌ایر', english_name: 'kish-air' },
                    { code: 'EP', persian_name: 'آسمان', english_name: 'aseman' },
                    { code: 'IR', persian_name: 'ایران‌ایر', english_name: 'iran-air' },
                    { code: 'SR', persian_name: 'سپهران', english_name: 'sepehran' }]

iranian_airlines.each do |airline|
  x = Airline.find_by(code: airline[:code], english_name: airline[:english_name])
  x.country_code = 'IR'
  x.save
end

# Creating routes
cities = City.where("country_code= 'IR' AND priority < ?", 10).map(&:city_code)
cities.each do |origin|
  cities.each do |destination|
    next if origin == destination

    Route.create(origin: origin, destination: destination)
  end
end
