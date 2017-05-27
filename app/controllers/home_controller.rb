class HomeController < ApplicationController

  def index
    @cities ={thr:"تهران",mhd:"مشهد",kih:"کیش",syz:"شیراز",ifn:"اصفهان"}
    @flight_price_showoff_cities =["syz","kih","mhd"]
    @default_destination_city ="kih"
  end

end