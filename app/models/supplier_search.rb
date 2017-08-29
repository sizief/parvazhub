class SupplierSearch

	def search(origin,destination,date)
	  route = Route.find_by(origin:"#{origin}", destination:"#{destination}")
    #search_suppliers(20,origin,destination,route.id,date) 
    search_supplier_in_threads(20,origin,destination,route.id,date) 
	end

  def background_search(origin,destination,date)
    ActiveRecord::Base.connection_pool.with_connection do   
      route = Route.find_by(origin:"#{origin}", destination:"#{destination}")
      #search_suppliers(60,origin,destination,route.id,date) 
      search_supplier_in_threads(40,origin,destination,route.id,date) 
      
    end
  end

  def search_supplier_in_threads(delay,origin,destination,route_id,date)
    threads = []
    supplier_list = Supplier.where(status:true)
    begin 
      
      Timeout.timeout(delay) do
        supplier_list.each do |supplier|
          threads << Thread.new do
            search_supplier(supplier[:name],supplier[:class_name],origin,destination,route_id,date,"user")
          end
        end
        # Join on the child processes to allow them to finish
        threads.each do |thread|
          thread.join
        end
      end
    rescue Timeout::Error
    end
  end

	def search_suppliers(delay,origin,destination,route_id,date)
    job_ids = Hash.new
    supplier_list = nil
    ActiveRecord::Base.connection_pool.with_connection do   
      supplier_list = Supplier.where(status:true)
    end

    supplier_list.each do |x|
      job_ids[x[:name].to_sym] = SupplierSearchWorker.perform_async(x[:name],x[:class_name],origin,destination,route_id,date,"bg")
    end
    wait_to_finish_all_requests(delay,job_ids)
  end

  def wait_to_finish_all_requests (delay,job_ids)
    1.upto(delay.to_i) do 
      results_ready = Array.new
      job_ids.each do |key,value|
      	 results_ready << (Sidekiq::Status::complete? value)
      end
      if (results_ready.all? {|x| x == true })
      	break
      else
      	sleep 1 
      end
    end	
  end

  def search_supplier(supplier_name,supplier_class,origin,destination,route_id,date,who_started)
      search_history = nil
      flight_list = supplier_class.constantize.new()
      
      ActiveRecord::Base.connection_pool.with_connection do        
        search_history = SearchHistory.create(supplier_name:"#{supplier_name}",route_id:route_id,departure_time: date,status:"#{who_started} Started(#{Time.now.strftime('%M:%S')})")
      end
      
      response = flight_list.search(origin,destination,date,search_history.id)

      if response[:status] == true
        log(supplier_name,response[:response]) if Rails.env.development?  
        flight_list.import_domestic_flights(response,route_id,origin,destination,date,search_history.id)
        update_flight_best_price(origin,destination,date) 
      end
  end

  def update_flight_best_price(origin,destination,date) 
    ActiveRecord::Base.connection_pool.with_connection do   
      Flight.update_best_price(origin,destination,date) 
    end
  end

	def log(supplier_name,response)
	  log_file_path_name = "log/supplier/#{supplier_name}"+Time.now.to_s+".log"
	  log_file = File.new("#{log_file_path_name}", "w")
	  log_file.puts(response)
	  log_file.close
	end

end