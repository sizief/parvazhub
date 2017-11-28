class SupplierSearch
  attr_reader :origin,:destination,:date,:timeout,:who_started,:route
  
  def initialize args
    @origin = args[:origin]
    @destination = args[:destination]
    @date = args[:date]
    @timeout = args[:timeout]
    @who_started = args[:who_started]
    @route = Route.find_by(origin:"#{origin}", destination:"#{destination}")
  end

	def search
    #search_supplier_in_threads
    search_supplier_in_series
	end

  def search_supplier_in_series 
    flight_ids = Array.new
    suppliers = supplier_list

    begin 
      suppliers.each do |supplier|
        begin
          search_supplier(supplier[:name],supplier[:class_name])
        rescue
          raise if Rails.env.development?
        end
      end
      
      merge_and_update_all(flight_ids,route,date)
    rescue 
      raise if Rails.env.development?
    end

  end

  def flight_ids
    SearchHistoryFlightId.get_ids search_history_id
  end

  def supplier_list
    route.international ? Supplier.where(status:true, international: true) : Supplier.where(status:true, domestic: true)
  end

  def merge_and_update_all (flight_ids,route,date)
    Flight.update_flight_price_count flight_ids        
    update_flight_best_price
  end

  def search_supplier(supplier_name,supplier_class)
    search_history = nil
    ActiveRecord::Base.connection_pool.with_connection do 
      search_history = SearchHistory.create(supplier_name:"#{supplier_name}",route_id:route.id,departure_time: date,status:"#{who_started} Started(#{Time.now.strftime('%M:%S')})")
    end  
    supplier = supplier_class.constantize.new(origin: origin,
                                                destination: destination,
                                                route: route,
                                                date: date,
                                                search_history_id: search_history.id)


      
    results = supplier.search
    return results
  end

  def update_flight_best_price
    ActiveRecord::Base.connection_pool.with_connection do   
      Flight.update_best_price route, date
    end
  end

	

end