class CityPageController < ApplicationController
  include CityPageHelper
  
  def index
    @prices = Hash.new
	  @city_code = City.get_city_code_based_on_english_name params[:city_name]
	  not_found unless @city_code 

    @city = City.list[@city_code.to_sym]
    
    @prices[:from_thr] = Flight.new.get_lowest_price_for_month("thr",@city_code)
    @prices[:to_thr] = Flight.new.get_lowest_price_for_month(@city_code,"thr")
    @prices = prepare_for_calendar_view @prices
  end

  def not_found
  	raise ActionController::RoutingError.new('Not Found')
  end

end