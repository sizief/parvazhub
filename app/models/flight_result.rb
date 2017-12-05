class FlightResult 
  attr_reader :route, :date

  def initialize(route,date)
    @route = route
    @date = date
  end

  def get
    result_time_to_live = FlightResult.allow_response_time(date)
    response_available = SearchHistory.where(route_id:route.id,departure_time:"#{date}")
                                      .where('created_at >= ?', result_time_to_live)
                                      .count
    if ((response_available == 0) and (date >= Date.today.to_s))
        timeout = route.international? ? ENV["TIMEOUT_INTERNATIONAL"].to_i : ENV["TIMEOUT_DOMESTIC"].to_i
        SupplierSearch.new(origin: route.origin,
                                  destination: route.destination,
                                  date: date,
                                  timeout: timeout,
                                  who_started: "user").search
    end
    Flight.new.flight_list(route,date,result_time_to_live)
  end
  
  def self.allow_response_time(date)
    if date == Date.today.to_s #today
      allow_time = ENV["SUPPLIER_SESSION_TIMEOUT"].to_i/2
    else 
      allow_time = ENV["SUPPLIER_SESSION_TIMEOUT"].to_i
    end
    allow_time.to_f.minutes.ago
  end

end