# frozen_string_literal: true

class FlightResult
  attr_reader :route, :date

  def initialize(route = nil, date = nil)
    @route = route
    @date = date
  end

  def call
    result_time_to_live = allow_response_time(date)

    if !response_available? && (date >= Date.today.to_s)
      timeout = route.international? ? ENV['TIMEOUT_INTERNATIONAL'].to_i : ENV['TIMEOUT_DOMESTIC'].to_i
      SupplierSearch.new(
        origin: route.origin,
        destination: route.destination,
        date: date,
        timeout: timeout,
        search_initiator: 'user'
      ).search
    end
    Flight.new.flight_list(route, date, result_time_to_live)
  end

  def archive
    Flight.new.flight_list(route, date, 1440.to_f.minutes.ago)
  end

  def get_flight_price(flight)
    result_time_to_live = allow_response_time flight.departure_time.to_date.to_s
    FlightPrice.new.get(flight.id, result_time_to_live)
  end

  private

  def response_available?
    SearchHistory
      .where(route_id: route.id, departure_time: date.to_s)
      .where('created_at >= ?', allow_response_time(date))
      .count > 0
  end

  def allow_response_time(_date)
    allow_time = ENV['SUPPLIER_SESSION_TIMEOUT'].to_i
    allow_time.to_f.minutes.ago
  end
end
