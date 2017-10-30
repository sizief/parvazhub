class ApiController < ApplicationController
    
    def airports
        airports = Array.new
        cities = City.list
        cities.each do |city|
            value = city[1][:fa]
            key = city[1][:en] 
            airports << {'code': key, 'value': "#{value} - #{key} "}
        end
        render json: airports
        
    end    
end
