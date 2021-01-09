# frozen_string_literal: true
supplier_list = [{ "id": 7, "name": 'trip', "class_name": 'Suppliers::Trip', "status": false, "created_at": '2017-08-13T13:25:20.875Z', "updated_at": '2018-07-16T21:10:09.564Z', "international": true, "domestic": true, "job_search_allowed": false, "rate_count": 0, "rate_average": 0 }, { "id": 5, "name": 'ghasedak', "class_name": 'Suppliers::Ghasedak', "status": true, "created_at": '2017-08-07T00:00:00.000Z', "updated_at": '2018-07-16T22:00:11.036Z', "international": false, "domestic": true, "job_search_allowed": false, "rate_count": 4, "rate_average": 3 }, { "id": 11, "name": 'safarestan', "class_name": 'Suppliers::Safarestan', "status": true, "created_at": '2018-01-20T08:30:51.844Z', "updated_at": '2018-06-29T16:34:29.764Z', "international": false, "domestic": true, "job_search_allowed": false, "rate_count": 4, "rate_average": 5 }, { "id": 1, "name": 'flightio', "class_name": 'Suppliers::Flightio', "status": true, "created_at": '2017-06-10T14:33:43.632Z', "updated_at": '2018-06-29T17:01:17.159Z', "international": false, "domestic": true, "job_search_allowed": false, "rate_count": 4, "rate_average": 5 }, { "id": 3, "name": 'alibaba', "class_name": 'Suppliers::Alibaba', "status": false, "created_at": '2017-06-10T14:33:43.644Z', "updated_at": '2018-03-13T22:15:18.085Z', "international": false, "domestic": true, "job_search_allowed": false, "rate_count": 0, "rate_average": 0 }, { "id": 6, "name": 'respina', "class_name": 'Suppliers::Respina24', "status": false, "created_at": '2017-08-09T00:00:00.000Z', "updated_at": '2018-03-13T22:15:18.116Z', "international": false, "domestic": true, "job_search_allowed": false, "rate_count": 0, "rate_average": 0 }]

supplier_list.each do |supplier|
  Supplier.create(name: supplier[:name],
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
