class StaticPagesController < ApplicationController
  def about_us
  end

  def cheap_flights
    @cities = City.list 
    @default_destination_city = City.default_destination_city
  end
end
