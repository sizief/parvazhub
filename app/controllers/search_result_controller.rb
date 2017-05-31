class SearchResultController < ApplicationController

  def search
    origin = params[:search][:origin].downcase
    destination = params[:search][:destination].downcase
    #TODO: what the following line do? its already string
    date = Date.parse params[:search][:date]
    date = date.to_s

    route = Route.find_by(origin:"#{origin}", destination:"#{destination}")

    if route.nil?
      notfound
    else
      UserSearchHistory.create(route_id:route.id,departure_time:"#{date}") #save user search to show in admin panel
      response_available = SearchHistory.where(route_id:route.id,departure_time:"#{date}").where('created_at >= ?', ENV["SEARCH_RESULT_VALIDITY_TIME"].to_f.minutes.ago).count
      SupplierSearch.new.search(origin,destination,date) if response_available == 0
      index(route,origin,destination,date)
    end
  end

  def notfound
    @default_destination_city = City.default_destination_city
    @cities = City.list 
    render :notfound
  end

  def index(route,origin,destination,date)
     @flights = route.flights.where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s).where.not(best_price:0)
     @flights = @flights.sort_by(&:best_price)
     @search_parameter ={origin: origin,destination: destination,date: date}
     @cities = City.list 

     render :index
  end

  def flight_prices
    flight_id = params[:id]
    @flight_prices = FlightPrice.where(flight_id: params[:id]).order(:price)

    respond_to do |format|
        format.js 
        format.html
    end
  end

  def airport
    flight_list = Airports::Mehrabad.new
    response = flight_list.search
    flight_list.import_domestic_flights(response)
    
  end

end