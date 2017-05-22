class SearchController < ApplicationController

  def flight
  end

  def backgound_search_proccess(origin,destination,date)
    origin = origin.downcase
    destination = destination.downcase
    date = Date.parse date
    date = date.to_s

    route = Route.create_route("#{origin}", "#{destination}") #create id if id route is not exist
    search_suppliers(origin,destination,route.id,date)
  end

  def search_proccess
    origin = params[:search][:origin].downcase
    destination = params[:search][:destination].downcase
    date = Date.parse params[:search][:date]
    date = date.to_s

    route = Route.create_route("#{origin}", "#{destination}") #create id if id route is not exist
    UserSearchHistory.create(route_id:route.id,departure_time:"#{date}") #save user search to show in admin panel
    #check to see response from N minutes ago available or not. 
    response_available = SearchHistory.where(route_id:route.id,departure_time:"#{date}").where('created_at >= ?', ENV["SEARCH_RESULT_VALIDITY_TIME"].to_f.minutes.ago).count

    search_suppliers(origin,destination,route.id,date) if response_available == 0
    results(route,origin,destination,date)
  end

  def search_suppliers(origin,destination,route_id,date)
    supplier_list = [
      {class: Suppliers::Flightio,name: "flightio"},
      {class: Suppliers::Zoraq,name: "zoraq"},
      {class: Suppliers::Alibaba,name: "alibaba"}
    ]
    if Rails.env.production?  
      Parallel.each(supplier_list, in_threads: supplier_list.count) { |x| 
       search_supplier(x[:name],x[:class],origin,destination,route_id,date)
      }
    else
     Parallel.each(supplier_list, in_processes: supplier_list.count) { |x| 
       search_supplier(x[:name],x[:class],origin,destination,route_id,date)
      }
    end
  end

  def search_supplier(supplier_name,supplier_class,origin,destination,route_id,date)
    flight_list = supplier_class.new()
    search_history = SearchHistory.create(supplier_name:"#{supplier_name}",route_id:route_id,departure_time: date) #TODO: save the search status, false if it failed
    response = flight_list.search(origin,destination,date)
    
    if response == false
      search_history.update(status: "false")
    else
      log(response[:response]) if Rails.env.development?  
      flight_list.import_domestic_flights(response,route_id,origin,destination,date)
      search_history.update(status: "true")
    end
  end

  def results(route,origin,destination,date)
      #just to solve the connection issue between pgsql and rails, see https://github.com/grosser/parallel/issues/62
      begin
        ActiveRecord::Base.connection.reconnect!
      rescue
        ActiveRecord::Base.connection.reconnect!
      end

     @flights = route.flights.where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s)
     @flights.each do |flight|
        #stored_flight_prices = flight.flight_prices.select("price,supplier").where('created_at >= ?', ENV["SEARCH_RESULT_VALIDITY_TIME"].to_f.minutes.ago).order("price").first
         stored_flight_prices = flight.flight_prices.select("price,supplier").order("price").first

        if stored_flight_prices.nil? 
          flight.best_price = 0 #because we need to compare price in next step and if any nil exists then comparison failed
        else
          flight.best_price = stored_flight_prices.price 
          flight.price_by = stored_flight_prices.supplier 
        end
      end
     @flights = @flights.sort_by(&:best_price)
     @search_parameter ={origin: origin,destination: destination,date: date}
     render :results
  end

  def log(response)
    log_file_path_name = "log/supplier/"+Time.now.to_s+".log"
    log_file = File.new("#{log_file_path_name}", "w")
    log_file.puts(response)
    log_file.close
  end

  def flight_prices
    flight_id = params[:id]
    #@flight_prices = FlightPrice.where('created_at >= ?', ENV["SEARCH_RESULT_VALIDITY_TIME"].to_f.minutes.ago).where(flight_id: params[:id]).order(:price)
    @flight_prices = FlightPrice.where(flight_id: params[:id]).order(:price)

    respond_to do |format|
        format.js 
        format.html
    end
  end

end