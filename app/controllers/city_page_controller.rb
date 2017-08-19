class CityPageController < ApplicationController
  include CityPageHelper
  
  def city
    @prices = Hash.new
    @cities = City.list
   
	  @city_code = City.get_city_code_based_on_english_name params[:city_name]
	  not_found unless @city_code 

    @city = City.list[@city_code.to_sym]
    if @city_code == "thr"
      @destination = City.list[:mhd] 
      @prices[:to] = Flight.new.get_lowest_price_for_month("mhd",@city_code)
      @prices[:from] = Flight.new.get_lowest_price_for_month(@city_code,"mhd")
    else
      @destination = City.list[:thr] 
      @prices[:to] = Flight.new.get_lowest_price_for_month("thr",@city_code)
      @prices[:from] = Flight.new.get_lowest_price_for_month(@city_code,"thr")
    end
    
    @prices = prepare_for_calendar_view @prices
  end

  def not_found
  	raise ActionController::RoutingError.new('Not Found')
  end

  def route
    @prices = Hash.new
    @cities = City.list
   
	  @origin_code = City.get_city_code_based_on_english_name params[:origin_name]
    not_found unless @origin_code 
      
    @destination_code = City.get_city_code_based_on_english_name params[:destination_name]
	  not_found unless @destination_code 

    @origin = City.list[@origin_code.to_sym]
    @destination = City.list[@destination_code.to_sym]
    
    @prices[:to] = Flight.new.get_lowest_price_for_month(@origin_code,@destination_code)
    @prices[:from] = Flight.new.get_lowest_price_for_month(@destination_code,@origin_code)

    
    @prices = prepare_for_calendar_view @prices
  end
end