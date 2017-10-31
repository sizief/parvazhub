class HomeController < ApplicationController


  def index
    @cities = City.list 
    @flight_price_showoff_cities =["syz","kih","mhd","tbz"]
    @default_destination_city = City.default_destination_city
    @is_mobile = browser.device.mobile? 
  end
end