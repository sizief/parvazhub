class SearchController < ApplicationController

  def flight
  end

  def search_proccess
    origin = params[:search][:origin].downcase
    destination = params[:search][:destination].downcase
    date = Date.parse params[:search][:date]
    date = date.to_s
    route = Route.create_route("#{origin}", "#{destination}") #create id if id route is not exist
    response_available = SearchHistory.where(route_id:route.id,departure_time:"#{date}").where('created_at >= ?', ENV["SEARCH_RESULT_VALIDITY_TIME"].to_f.minutes.ago).count

    search_suppliers(origin,destination,route.id,date) if response_available == 0
    results(route,date)
  end

  def search_suppliers(origin,destination,route_id,date)
    Parallel.each([method(:search_alibaba),method(:search_zoraq)], in_processes: 2) { |x|
         x.call(origin,destination,route_id,date) 
    }

  end

  def search_alibaba(origin,destination,route_id,date)
    alibaba_response = Suppliers::Alibaba.search(origin,destination,date)
    SearchHistory.create(supplier_name:"Alibaba",route_id:route_id,departure_time: date)
    log(alibaba_response) if Rails.env.development?  
    flight_list = Flight.new()
    flight_list.import_domestic_alibaba_flights(alibaba_response,route_id,origin,destination,date)
  end

  def search_zoraq(origin,destination,route_id,date)
    zoraq_response = Suppliers::Zoraq.search(origin,destination,date)
    SearchHistory.create(supplier_name:"Zoraq",route_id:route_id,departure_time: date)
    log(zoraq_response) if Rails.env.development?  
    flight_list = Flight.new()
    flight_list.import_zoraq_flights(zoraq_response,route_id)
  end


  def results(route,date)
      #following code is implemented just to solve the connection issue between pgsql and rails, see https://github.com/grosser/parallel/issues/62
      begin
        ActiveRecord::Base.connection.reconnect!
      rescue
        ActiveRecord::Base.connection.reconnect!
      end

     @flights = route.flights.where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s)
     render :results
  end

  def log(response)
    log_file_path_name = "log/supplier/"+Time.now.to_s+".log"
    log_file = File.new("#{log_file_path_name}", "w")
    log_file.puts(response)
    log_file.close
  end

  



end