# frozen_string_literal: true

class SupplierSearch
  attr_reader :origin, :destination, :date, :timeout, :search_initiator, :route, :search_flight

  def initialize(args)
    @origin = args[:origin]
    @destination = args[:destination]
    @date = args[:date]
    @timeout = args[:timeout]
    @search_initiator = args[:search_initiator]
    @route = Route.find_by(origin: origin, destination: destination)
    @search_flight = SearchFlightId.create(token: DateTime.now.strftime('%Q'))
  end

  def call
    search_supplier_in_threads
    # search_supplier_in_threads if Rails.env.production?
    # search_supplier_in_series if Rails.env.development?
  end

  def search_supplier_in_threads
    threads = []
    Timeout.timeout(timeout) do
      suppliers.each do |supplier|
        threads << Thread.new do
          search_supplier(supplier[:name], supplier[:class_name])
        rescue StandardError => e
          HandleError.call(e)
        end
      end
      threads.each(&:join)
    end
    update_all_after_supplier_search
  rescue Timeout::Error
    update_all_after_supplier_search
    # kill threads
  rescue StandardError => e
    HandleError.call(e)
  end

  def search_supplier_in_series
    Timeout.timeout(timeout) do
      suppliers.each do |supplier|
        search_supplier(supplier[:name], supplier[:class_name])
      rescue StandardError => e
        HandleError.call(e)
      end
    end
    update_all_after_supplier_search
  rescue Timeout::Error
    update_all_after_supplier_search
  rescue StandardError => e
    HandleError.call(e)
  end

  def update_all_after_supplier_search
    merge_and_update_all(
      SearchFlightId.get_ids(
        search_flight.token
      )
    )
    SearchFlightId.where(token: search_flight.token).delete_all
  end

  def suppliers
    suppliers = route.international ? Supplier.where(status: true, international: true) : Supplier.where(status: true, domestic: true)

    return suppliers.where(job_search_allowed: true) if search_initiator == 'job_search'

    suppliers
  end

  def merge_and_update_all(flight_ids)
    update_flight_best_price
    Flight.update_flight_price_count flight_ids
  end

  def search_supplier(supplier_name, supplier_class)
    search_history = nil
    ActiveRecord::Base.connection_pool.with_connection do
      search_history = SearchHistory.create(
        supplier_name: supplier_name.downcase.to_s,
        route_id: route.id,
        departure_time: date,
        successful: false,
        status: Time.now.strftime('%M:%S').to_s
      )
    end
    supplier_class.constantize.new(
      origin: origin,
      destination: destination,
      route: route,
      date: date,
      search_history_id: search_history.id,
      search_flight_token: search_flight.token,
      supplier_name: supplier_name
    ).search
  end

  def update_flight_best_price
    Flight.update_best_price route, date
  end
end
