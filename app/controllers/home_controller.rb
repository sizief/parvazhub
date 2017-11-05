class HomeController < ApplicationController


  def index
    @flight_price_showoff_cities =[City.find_by(city_code:"syz"),
    City.find_by(city_code:"kih"),
    City.find_by(city_code:"mhd"),
    City.find_by(city_code:"tbz")]
    @is_mobile = browser.device.mobile? 
  end
end