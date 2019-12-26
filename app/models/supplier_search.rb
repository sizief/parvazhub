class SupplierSearch
  attr_reader :origin,:destination,:date,:timeout,:search_initiator,:route, :search_flight
  
  def initialize args
    @origin = args[:origin]
    @destination = args[:destination]
    @date = args[:date]
    @timeout = args[:timeout]
    @search_initiator = args[:search_initiator]
    @route = Route.find_by(origin: origin, destination: destination)
    @search_flight = SearchFlightId.create(token: DateTime.now.strftime('%Q'))
  end

  def search
    search_supplier_in_threads
    #search_supplier_in_series
  end
  
  def search_supplier_in_threads   
    threads = []
    flight_ids = Array.new    
    
    begin
      Timeout.timeout(timeout) do
        supplier_list.each do |supplier|
          threads << Thread.new do
            begin
              search_supplier(supplier[:name],supplier[:class_name])
            rescue
              raise if Rails.env.development?
            end
          end
        end  
        threads.each do |thread|
          thread.join  
        end    
      end
     
    rescue Timeout::Error
      # do nothing 
    rescue  
      raise if Rails.env.development?
    end 
    
    update_all_after_supplier_search
  end

  def search_supplier_in_series 
    flight_ids = Array.new
    suppliers = supplier_list
    begin 
      Timeout.timeout(timeout) do
        suppliers.each do |supplier|
          begin
            search_supplier(supplier[:name],supplier[:class_name])
          rescue
            raise if Rails.env.development?
          end
        end
      end
    rescue Timeout::Error
      # do nothing 
    rescue  
      raise if Rails.env.development?
    end 
      
    update_all_after_supplier_search
  end

  def update_all_after_supplier_search
    flight_ids = get_flight_ids
    merge_and_update_all(flight_ids,route,date)
    SearchFlightId.where(token: search_flight.token).delete_all
  end

  def get_flight_ids
    SearchFlightId.get_ids search_flight.token
  end

  def supplier_list 
    suppliers = route.international ? Supplier.where(status:true, international: true) : Supplier.where(status:true, domestic: true)
    suppliers = suppliers.where(job_search_allowed: true) if search_initiator == "job_search"
    return suppliers
  end

  def merge_and_update_all (flight_ids,route,date)
    update_flight_best_price
    Flight.update_flight_price_count flight_ids     
  end

  def search_supplier(supplier_name,supplier_class)
    search_history = nil
    ActiveRecord::Base.connection_pool.with_connection do 
      search_history = SearchHistory.create(supplier_name:"#{supplier_name.downcase}",
                                            route_id:route.id,
                                            departure_time: date,
                                            successful: false,
                                            status:"#{search_initiator}(#{Time.now.strftime('%M:%S')})")
    end  
    supplier = supplier_class.constantize.new(origin: origin,
                                                destination: destination,
                                                route: route,
                                                date: date,
                                                search_history_id: search_history.id,
                                                search_flight_token: search_flight.token,
                                                supplier_name: supplier_name)
    supplier.search      
  end

  def update_flight_best_price
    Flight.update_best_price route, date
  end

	

end
