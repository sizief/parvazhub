class HomeController < ApplicationController

  def index
    @city_pairs = [{origin: find_obj("thr"), destination: find_obj("mhd")},
                   {origin: find_obj("thr"), destination: find_obj("kih")},
                   {origin: find_obj("thr"), destination: find_obj("syz")},
                   {origin: find_obj("thr"), destination: find_obj("ist")}]
    
    @is_mobile = browser.device.mobile? 
  end

  def find_obj city_code
    City.find_by(city_code: city_code)
  end


end