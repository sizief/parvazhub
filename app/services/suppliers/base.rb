# frozen_string_literal: true

class Suppliers::Base
  attr_reader :origin, :destination, :date, :search_history, :supplier_name, :route, :search_flight_token

  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET,
    Errno::EINVAL,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error
  ].freeze

  def initialize(args)
    @origin = args[:origin]
    @destination = args[:destination]
    @date = args[:date]
    @search_history = SearchHistory.find(args[:search_history_id])
    @search_flight_token = args[:search_flight_token]
    @supplier_name = args[:supplier_name]
    @route = args[:route]
  end

  def search
    ActiveRecord::Base.connection_pool.with_connection do
      FlightPrice.delete_old_flight_prices(supplier_name.downcase, route.id, date)
    end

    response = search_supplier
    return unless response[:status]

    flight_ids = import_flights(response)
    save_flight_ids flight_ids
  rescue JSON::ParserError => e
    update_status(e)
  end

  def save_flight_ids(flight_ids)
    SearchFlightId.create(token: search_flight_token, flight_ids: flight_ids)
  end

  def calculate_stopover_duration(departures, arrivals)
    duration = 0
    if departures.count > 1
      departures.each_with_index do |departure, index|
        next if index.zero?

        duration += ((departure - arrivals[index - 1]) * 24 * 60).to_i
      end
    end
    duration
  end

  private

  def update_status(status)
    ActiveRecord::Base.connection_pool.with_connection do
      search_history.append(status)
    end
  end

  def complete_import(flight_prices)
    if flight_prices.empty?
      update_status('empty response')
    else
      ActiveRecord::Base.connection_pool.with_connection do
        FlightPrice.import flight_prices, validate: false
        FlightPriceArchive.archive flight_prices
      end
    end
    ActiveRecord::Base.connection_pool.with_connection do
      search_history.set_success
      update_status('done')
    end
  end
end
