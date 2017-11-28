class Suppliers::Base
  attr_reader :origin, :destination, :date, :search_history_id, :supplier_name, :route, :search_flight_token

  def initialize args
    @origin = args[:origin]
    @destination = args[:destination]
    @date = args[:date]
    @search_history_id = args[:search_history_id]
    @search_flight_token = args[:search_flight_token]
    @supplier_name = "trip"
    @route = args[:route]
    end

  def search
    flight_ids = nil
    response = search_supplier
    if response[:status] == true
      Log.new(log_name: supplier_name, content: response[:response]).save if Rails.env.development?        
      flight_ids = import_domestic_flights(response,route.id,origin,destination,date,search_history_id)
      save_flight_ids flight_ids
    end
  end

  def save_flight_ids flight_ids
    SearchFlightId.create(token: search_flight_token, flight_ids: flight_ids) 
  end
  
end
    