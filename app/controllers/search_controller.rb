class SearchController < ApplicationController
  def flight
  end

  def search_proccess
    origin = params[:search][:origin].downcase
    destination = params[:search][:destination].downcase
    date = params[:search][:date]
    route_id = Route.route_id(origin,destination)
    
    search_suppliers(origin,destination,route_id,date)
    
    render html: route_id
  end

  def search_suppliers(origin,destination,route_id,date)
    zoraq_response = Suppliers::Zoraq.search(origin,destination,date)
    flight_list = Flight.new()
    flight_list.import_zoraq_flights(zoraq_response,route_id)
  end

end