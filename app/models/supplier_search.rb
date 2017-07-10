class SupplierSearch

	def search(origin,destination,date)
	  route = Route.find_by(origin:"#{origin}", destination:"#{destination}")
    search_suppliers(15,origin,destination,route.id,date) 
    #update_flight_best_price(origin,destination,date) 
	end

  def background_search(origin,destination,date)
    route = Route.find_by(origin:"#{origin}", destination:"#{destination}")
    search_suppliers(30,origin,destination,route.id,date) 
    
  end

	def search_suppliers(delay,origin,destination,route_id,date)
    job_ids = Hash.new
    supplier_list = Supplier.where(status:true)

    supplier_list.each do |x|
      job_ids[x[:name].to_sym] = SupplierSearchWorker.perform_async(x[:name],x[:class_name],origin,destination,route_id,date)
    end
    wait_to_finish_all_requests(delay,job_ids)
  end

  def wait_to_finish_all_requests (delay,job_ids)
    1.upto(delay.to_i) do 
      results_ready = Array.new
      job_ids.each do |key,value|
      	 #puts "#{key}" + (Sidekiq::Status::complete? value).to_s
      	 results_ready << (Sidekiq::Status::complete? value)
      end
      if (results_ready.all? {|x| x == true })
      	break
      else
      	sleep 1 
      end
    end	
  end

  	def search_supplier(supplier_name,supplier_class,origin,destination,route_id,date)
      flight_list = supplier_class.constantize.new()
      search_history = SearchHistory.create(supplier_name:"#{supplier_name}",route_id:route_id,departure_time: date,status:"waiting")
      response = flight_list.search(origin,destination,date)
      if response[:status] == false
        search_history.update(status: response[:response])
      else
        log(response[:response]) if Rails.env.development?  
        flight_list.import_domestic_flights(response,route_id,origin,destination,date)
        search_history.update(status: "true")
        update_flight_best_price(origin,destination,date) 
      end
  	end

  	def update_flight_best_price(origin,destination,date) 
	  Flight.update_best_price(origin,destination,date) 
    end

	def log(response)
	  log_file_path_name = "log/supplier/"+Time.now.to_s+".log"
	  log_file = File.new("#{log_file_path_name}", "w")
	  log_file.puts(response)
	  log_file.close
	end

end