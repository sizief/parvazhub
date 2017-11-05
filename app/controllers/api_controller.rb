class ApiController < ApplicationController
    
    def cities_prefetch_suggestion
        city_list = Array.new
        cities = City.where(country_code: "IR").order(:priority)
        cities.each do |city|
            value = city.persian_name
            key = city.english_name
            city_list << {'code': key, 'value': "#{value} - #{key} "}
        end
        render json: city_list  
    end    
end
