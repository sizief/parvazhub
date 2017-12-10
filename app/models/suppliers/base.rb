class Suppliers::Base
  attr_reader :origin, :destination, :date, :search_history_id, :supplier_name, :route, :search_flight_token, :supplier_name

  def initialize args
    @origin = args[:origin]
    @destination = args[:destination]
    @date = args[:date]
    @search_history_id = args[:search_history_id]
    @search_flight_token = args[:search_flight_token]
    @supplier_name = args[:supplier_name]
    @route = args[:route]
  end

  def search
    flight_ids = nil
    ActiveRecord::Base.connection_pool.with_connection do       
      FlightPrice.delete_old_flight_prices(supplier_name.downcase,route.id,date)
      SearchHistory.append_status(search_history_id,"delete(#{Time.now.strftime('%M:%S')})")
    end
    
    response = search_supplier
    if response[:status] == true
      Log.new(log_name: supplier_name, content: response[:response]).save if Rails.env.development?        
      flight_ids = import_flights(response,route.id,origin,destination,date,search_history_id)
      save_flight_ids flight_ids
    end
  end

  def save_flight_ids flight_ids
    SearchFlightId.create(token: search_flight_token, flight_ids: flight_ids) 
  end

  def mock_results
    if route.international
      file = "international-#{supplier_name.downcase}.log"
    else
      file = "domestic-#{supplier_name.downcase}.log"
    end
    response = File.read("test/fixtures/files/"+file)
  end

  def calculate_stopover_duration (departures,arrivals)
    duration = 0    
    if departures.count > 1
      departures.each_with_index do |departure,index|
        next if index == 0
        duration += ((departure - arrivals[index-1])*24*60).to_i        
      end
    end
    duration
  end

  
end
    