# frozen_string_literal: true

class Suppliers::Base
  attr_reader :origin, :destination, :date, :search_history, :supplier_name, :route, :flight_prices

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
    @flight_prices = {}
  end

  def search
    ActiveRecord::Base.connection_pool.with_connection do
      FlightPrice.delete_old_flight_prices(route, date)
    end

    response = search_supplier
    return unless response[:status]

    import_flights(response)
    import_flight_prices
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

  def add_to_flight_prices(flight_price)
    key = flight_price.flight_id
    unless flight_prices.key?(key)
      flight_prices[key] = flight_price
      return
    end

    return if flight_prices[key].price.to_i <= flight_price.price.to_i

    flight_prices[key] = flight_price
  end

  def update_status(status)
    ActiveRecord::Base.connection_pool.with_connection do
      search_history.append(status)
    end
  end

  def import_flight_prices
    if flight_prices.values.empty?
      update_status('empty response')
    else
      ActiveRecord::Base.connection_pool.with_connection do
        FlightPrice.import flight_prices.values, validate: false
        FlightPriceArchive.archive flight_prices.values
      end
    end
    ActiveRecord::Base.connection_pool.with_connection do
      search_history.set_success
      update_status('done')
    end
  end

  def airline_code_correction(code)
    airlines = {
      'RV' => 'IV',
      'ZZ' => 'SR',
      'RZ' => 'SR',
      'IS' => 'SR',
      'SE' => 'SR'
    }
    airlines[code].nil? ? code : airlines[code]
  end

  def flight_number_correction(flight_number, airline_code)
    if flight_number.include? airline_code
      flight_number = flight_number.sub(airline_code, '')
    end
    flight_number.gsub(/[^\d,\.]/, '')
  end
end
