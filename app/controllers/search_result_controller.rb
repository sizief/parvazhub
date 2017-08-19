class SearchResultController < ApplicationController

  def flight_search
    origin = params[:search][:origin].downcase
    destination = params[:search][:destination].downcase
    date = Date.parse params[:search][:date]
    redirect_to  action: 'search', origin_name: origin, destination_name: destination, date: date
  end

  def search
    origin_name = params[:origin_name].downcase
    destination_name = params[:destination_name].downcase
    date = Date.parse params[:date]
    #TODO: what the following line do? its already string
    date = date.to_s

    origin_code = City.get_city_code_based_on_english_name origin_name
    destination_code = City.get_city_code_based_on_english_name destination_name
    route = Route.find_by(origin:"#{origin_code}", destination:"#{destination_code}")

    if route.nil?
      notfound
    else
      UserSearchHistory.create(route_id:route.id,departure_time:"#{date}") #save user search to show in admin panel
      response_available = SearchHistory.where(route_id:route.id,departure_time:"#{date}").where('created_at >= ?', ENV["SEARCH_RESULT_VALIDITY_TIME"].to_f.minutes.ago).count
      SupplierSearch.new.search(origin_code,destination_code,date) if response_available == 0
      index(route,origin_name,origin_code,destination_name,destination_code,date)
    end
  end

  def notfound
    @default_destination_city = City.default_destination_city
    @cities = City.list 
    render :notfound
  end

  def index(route,origin_name,origin_code,destination_name,destination_code,date)
     @flights = Flight.new.flight_list(route,date)
     @search_parameter ={origin_name: origin_name, origin_code: origin_code, destination_code: destination_code, destination_name: destination_name,date: date}
     @cities = City.list 

     render :index
  end

  def flight_prices
    @dates = Array.new
    @prices = Array.new
    flight_id = params[:id]
    flight_date = Flight.find(flight_id).departure_time.to_date.to_s
    @flight_prices = FlightPrice.where(flight_id: params[:id]).order(:price)
    @flight_price_over_time = FlightPriceArchive.flight_price_over_time(flight_id,flight_date)
    @flight_price_over_time.each do |date,price|
      @dates <<  date.to_s.to_date.to_parsi.strftime("%A %d %B")
      @prices << price
    end
    
    respond_to do |format|
        format.js 
        format.html
    end
  end

end