class FlightResult 
  attr_reader :route, :date

  def initialize(route=nil,date=nil)
    @route = route
    @date = date
  end

  def get
    result_time_to_live = allow_response_time date
    response_available = SearchHistory.where(route_id:route.id,departure_time:"#{date}")
                                      .where('created_at >= ?', result_time_to_live)
                                      .count
    if ((response_available == 0) and (date >= Date.today.to_s))
        timeout = route.international? ? ENV["TIMEOUT_INTERNATIONAL"].to_i : ENV["TIMEOUT_DOMESTIC"].to_i
        SupplierSearch.new(origin: route.origin,
                                  destination: route.destination,
                                  date: date,
                                  timeout: timeout,
                                  search_initiator: "user").search
    end
    Flight.new.flight_list(route,date,result_time_to_live)
  end

  def get_archive
    Flight.new.flight_list(route,date,1440.to_f.minutes.ago)
  end 

  def get_flight_price flight
    result_time_to_live = allow_response_time flight.departure_time.to_date.to_s
    FlightPrice.new.get(flight.id,result_time_to_live)
  end

  private
  def allow_response_time(date) 
    allow_time = ENV["SUPPLIER_SESSION_TIMEOUT"].to_i
    allow_time.to_f.minutes.ago
  end

end