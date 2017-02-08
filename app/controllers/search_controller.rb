class SearchController < ApplicationController

  def flight
  end

  def search_proccess
    origin = params[:search][:origin].downcase
    destination = params[:search][:destination].downcase
    date = params[:search][:date]
    #route = Route.find_by(origin: "#{origin}", destination:"#{destination}") #Find route. This works only if route already exists
    route = Route.create_route("#{origin}", "#{destination}") #create id if id route is not exist

    
    #FlightSearchWorker.perform_async(origin,destination,route.id,date) #Search Async
    #FlightSearchWorker.new.perform(origin,destination,route.id,date)  #Search sync
    search_suppliers(origin,destination,route.id,date)  #Search without sidekiq
    
    results(route,date)
  end

  def search_suppliers(origin,destination,route_id,date)
    zoraq_response = Suppliers::Zoraq.search(origin,destination,date)
    log(zoraq_response) if Rails.env.development?  

    alibaba_response = Suppliers::Alibaba.search(origin,destination,date)
    log(alibaba_response) if Rails.env.development?  

    flight_list = Flight.new()
    flight_list.import_zoraq_flights(zoraq_response,route_id)
    flight_list.import_domestic_alibaba_flights(alibaba_response,route_id)

  end

  def results(route,date)
     @flights = route.flights.where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s)
      #debugger
     render :results
  end

  def log(response)
    log_file_path_name = "log/supplier/"+Time.now.to_s+".log"
    log_file = File.new("#{log_file_path_name}", "w")
    log_file.puts(response)
    log_file.close
  end

  



end