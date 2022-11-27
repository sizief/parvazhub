# frozen_string_literal: true

class SupplierSearch
  attr_reader :origin, :destination, :date, :timeout, :search_initiator, :route

  def initialize(args)
    @origin = args[:origin]
    @destination = args[:destination]
    @date = args[:date]
    @timeout = args[:timeout]
    @search_initiator = args[:search_initiator]
    @route = Route.find_by(origin: origin, destination: destination)
  end

  def call
    # search_supplier_in_threads
     search_supplier_in_threads if Rails.env.production?
     search_supplier_in_series if Rails.env.development?
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
    post_search_action
  rescue Timeout::Error
    post_search_action
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
    post_search_action
  rescue Timeout::Error
    post_search_action
  rescue StandardError => e
    HandleError.call(e)
  end

  def post_search_action
    Flight.update_best_price route, date
  end

  def suppliers
    suppliers = route.international ? Supplier.where(status: true, international: true) : Supplier.where(status: true, domestic: true)

    return suppliers.where(job_search_allowed: true) if search_initiator == 'job_search'

    suppliers
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
      search_history: search_history,
      supplier_name: supplier_name
    ).search
  end
end
