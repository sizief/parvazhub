class SupplierSearch

	def search(origin,destination,date)
		route = Route.find_by(origin:"#{origin}", destination:"#{destination}")
	    search_suppliers(origin,destination,route.id,date) 
	    update_flight_best_price(origin,destination,date) 
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

  	def update_flight_best_price(origin,destination,date) 
    	#just to solve the connection issue between pgsql and rails, see https://github.com/grosser/parallel/issues/62
		begin
			ActiveRecord::Base.connection.reconnect!
		rescue
			ActiveRecord::Base.connection.reconnect!
		end
		Flight.update_best_price(origin,destination,date) 
  	end

	def log(response)
		log_file_path_name = "log/supplier/"+Time.now.to_s+".log"
		log_file = File.new("#{log_file_path_name}", "w")
		log_file.puts(response)
		log_file.close
	end

end