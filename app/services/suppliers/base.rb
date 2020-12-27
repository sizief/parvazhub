# frozen_string_literal: true

class Suppliers::Base
  attr_reader :origin, :destination, :date, :search_history, :supplier_name, :route

  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET,
    Errno::EINVAL,
    Errno::ECONNREFUSED,
    Errno::EHOSTUNREACH,
    Errno::EACCES,
    Errno::EFAULT,
    Errno::ENOENT,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error,
    JSON::ParserError,
    RestClient::Forbidden,
    RestClient::Unauthorized
  ].freeze

  def initialize(
    origin:,
    destination:,
    date:,
    search_history:,
    supplier_name:,
    route:
  )
    @origin = origin
    @destination = destination
    @date = date
    @search_history = search_history
    @supplier_name = supplier_name
    @route = route
  end

  def search
    ActiveRecord::Base.connection_pool.with_connection do
      FlightPrice.delete_old_flight_prices(route, date)
    end

    response = search_supplier
    return unless response[:status]

    import_flights(response)
  rescue StandardError => e
    HandleError.call(e)
    update_status(e)
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
      unique_fps = remove_duplicate(flight_prices)
      ActiveRecord::Base.connection_pool.with_connection do
        FlightPrice.import unique_fps, validate: false
        FlightPriceArchive.archive unique_fps
      end
    end
    ActiveRecord::Base.connection_pool.with_connection do
      search_history.set_success
      update_status('done')
    end
  end

  def remove_duplicate(flight_prices)
    unique_fps = []
    flight_prices.each do |fp|
      duplicate = unique_fps.select { |u| u.supplier == fp.supplier and u.flight_id == fp.flight_id }
      next if duplicate.count.positive?

      unique_fps << fp
    end
    unique_fps
  end
end
