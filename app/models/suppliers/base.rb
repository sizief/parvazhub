# frozen_string_literal: true

class Suppliers::Base
  attr_reader :origin, :destination, :date, :search_history_id, :supplier_name, :route, :search_flight_token, :supplier_name

  def initialize(args)
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
      FlightPrice.delete_old_flight_prices(supplier_name.downcase, route.id, date)
    end
    update_status(search_history_id, "delete(#{Time.now.strftime('%M:%S')})")

    response = search_supplier
    if response[:status] == true
      if Rails.env.development?
        Log.new(log_name: supplier_name, content: response[:response]).save
      end
      flight_ids = import_flights(response, route.id, origin, destination, date, search_history_id)
      save_flight_ids flight_ids
    end
  end

  def save_flight_ids(flight_ids)
    SearchFlightId.create(token: search_flight_token, flight_ids: flight_ids)
  end

  def mock_results
    file = if route.international
             "international-#{supplier_name.downcase}.log"
           else
             "domestic-#{supplier_name.downcase}.log"
           end
    response = File.read('test/fixtures/files/' + file)
  end

  def calculate_stopover_duration(departures, arrivals)
    duration = 0
    if departures.count > 1
      departures.each_with_index do |departure, index|
        next if index == 0

        duration += ((departure - arrivals[index - 1]) * 24 * 60).to_i
      end
    end
    duration
  end

  private

  def update_status(search_history_id, text)
    if Rails.env.development?
      ActiveRecord::Base.connection_pool.with_connection do
        SearchHistory.append_status(search_history_id, text)
      end
    end
  end

  def successful_search(search_history_id)
    ActiveRecord::Base.connection_pool.with_connection do
      SearchHistory.find(search_history_id).update(successful: true)
    end
  end

  def complete_import(flight_prices, search_history_id)
    if flight_prices.empty?
      update_status(search_history_id, "empty response(#{Time.now.strftime('%M:%S')})")
    else
      ActiveRecord::Base.connection_pool.with_connection do
        update_status(search_history_id, "p done(#{Time.now.strftime('%M:%S')})")
        FlightPrice.import flight_prices, validate: false
        update_status(search_history_id, "fp(#{Time.now.strftime('%M:%S')})")
        FlightPriceArchive.archive flight_prices
        update_status(search_history_id, "Success(#{Time.now.strftime('%M:%S')})")
      end
      update_status(search_history_id, "Success(#{Time.now.strftime('%M:%S')})")
    end
    successful_search search_history_id
  end
end
