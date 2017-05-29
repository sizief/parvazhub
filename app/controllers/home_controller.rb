class HomeController < ApplicationController

  def index
    @cities = City.list 
    @flight_price_showoff_cities =["syz","kih","mhd"]
    @default_destination_city = City.default_destination_city
  end
end