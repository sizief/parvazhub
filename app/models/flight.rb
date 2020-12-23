# frozen_string_literal: true

class Flight < ApplicationRecord
  # validates :flight_number, :uniqueness => { :scope => :departure_time,:message => "already saved" }
  validates_uniqueness_of :route_id, scope: %i[flight_number departure_time]

  # validates :route_id, presence: true
  belongs_to :route
  has_many :flight_prices
  has_one :flight_info

  attr_accessor :suppliers_count
  attr_accessor :airline_persian_name
  attr_accessor :airline_english_name
  attr_accessor :airline_rate_average
  attr_accessor :best_price_dollar

  def self.create_or_find_flight(route_id, flight_number, departure_time, airline_code, airplane_type, arrival_date_time = nil, stops = nil, trip_duration = nil)
    ActiveRecord::Base.connection_pool.with_connection do
      begin
        flight = Flight.create(route_id: route_id, flight_number: flight_number, departure_time: departure_time, arrival_date_time: arrival_date_time, airline_code: airline_code, airplane_type: airplane_type, stops: stops, trip_duration: trip_duration)
        unless flight.id # flight is already exists
          flight = Flight.find_by(route_id: route_id, flight_number: flight_number, departure_time: departure_time)
        end
      rescue StandardError
        flight = Flight.find_by(route_id: route_id, flight_number: flight_number, departure_time: departure_time)
      end
      binding.pry if flight.nil?
      flight.id
    end
  end

  def self.update_best_price(route, date)
    flights = route.flights.where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s)
    flights.each do |flight|
      stored_flight_prices = flight.flight_prices.select('price,supplier').order('price').first
      if stored_flight_prices.nil?
        flight.best_price = 0 # means the flight is no longer available
      else
        flight.best_price = stored_flight_prices.price
        flight.price_by = stored_flight_prices.supplier
        flight.updated_at = Time.now # ensure that the updated at is going to update even if the value is not changed
      end
      flight.save
    end
  end

  def self.update_flight_price_count(flight_ids)
    flight_ids.each { |flight_id| Flight.reset_counters(flight_id, :flight_prices) }
  end

  def get_lowest_price_timetable(origin, destination, date)
    route = Route.find_by(origin: origin, destination: destination)
    starting_date = if date.to_date == Date.today
                      date
                    elsif date.to_date == (Date.today + 1)
                      (date.to_date - 1).to_s
                    else
                      (date.to_date - 2).to_s
                    end

    prices = []
    dates = [starting_date.to_date.to_s, (starting_date.to_date + 1).to_s, (starting_date.to_date + 2).to_s, (starting_date.to_date + 3).to_s, (starting_date.to_date + 4).to_s]
    dates.each do |selected_date|
      price = {}
      price[:date] = selected_date
      flight = get_lowest_price(route, selected_date)
      price[:price] = flight.nil? ? nil : flight.best_price
      price[:price_dollar] = flight.nil? ? nil : to_dollar(flight.best_price)
      prices << price
    end
    prices
  end

  def get_lowest_price_for_a_month(origin, destination, start_date)
    duration = 21
    prices = []
    route = Route.find_by(origin: origin, destination: destination)
    0.upto(duration) do |x|
      price = {}
      selected_date = (start_date + x).to_s
      price[:date] = selected_date
      flight = get_lowest_price(route, selected_date)
      price[:price] = flight.nil? ? nil : flight.best_price
      price[:price_dollar] = flight.nil? ? nil : to_dollar(flight.best_price)
      prices << price
    end
    prices
  end

  def get_lowest_price(route, date)
    begin
       flight = route.flights.where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s).where.not(best_price: 0).min_by(&:best_price)
       flight.best_price_dollar = to_dollar(flight.best_price)
    rescue StandardError
      flight = nil
     end
    flight
  end

  def airline_call_sign(airline_code)
    airlines = { 'W5' => 'IRM',
                 'AK' => 'ATR',
                 'B9' => 'IRB',
                 'sepahan' => 'SON',
                 'hesa' => 'SON',
                 'I3' => 'TBZ',
                 'JI' => 'MRJ',
                 'IV' => 'CPN',
                 'NV' => 'IRG',
                 'SE' => 'IRZ',
                 'ZV' => 'IZG',
                 'HH' => 'TBN',
                 'QB' => 'QSM',
                 'Y9' => 'KIS',
                 'EP' => 'IRC',
                 'IR' => 'IRA',
                 'SR' => 'SHI' }
    airlines[airline_code].nil? ? airline_code : airlines[airline_code]
  end

  def flight_list(route, date, result_time_to_live)
    airline_list = Airline.list
    responses = []
    flight_list = route.flights.includes(:flight_info)
                       .where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s)
                       .where.not(best_price: 0)
                       .where.not(airline_code: nil)
                       .where.not(airline_code: '')
                       .where('updated_at >= ?', result_time_to_live)
                       .order(:best_price)

    flight_list.each do |flight|
      response = {}
      response[:id] = flight.id
      response[:flight_number] = flight.flight_number
      response[:departure_time] = flight.departure_time
      response[:best_price] = flight.best_price
      response[:best_price_dollar] = to_dollar(flight.best_price)
      response[:price_by] = flight.price_by
      response[:arrival_date_time] = flight.arrival_date_time
      response[:trip_duration] = flight.trip_duration
      response[:stops] = flight.stops

      response[:supplier_count] = flight.flight_prices_count
      response[:airline_code] = flight.airline_code.split(',')[0]
      flight.airline_code = flight.airline_code.split(',').first # get first flight for multipart flights

      # temp_airline_code = flight.airline_code.nil? ? "empty" : flight.airline_code
      if airline_list[flight.airline_code.to_sym].nil?
        response[:airline_english_name] = flight.airline_code
        response[:airline_persian_name] = flight.airline_code
        response[:airline_rate_average] = 0
      else
        response[:airline_english_name] = airline_list[flight.airline_code.to_sym][:english_name]
        response[:airline_persian_name] = airline_list[flight.airline_code.to_sym][:persian_name]
        response[:airline_rate_average] = airline_list[flight.airline_code.to_sym][:rate_average].nil? ? 0 : airline_list[flight.airline_code.to_sym][:rate_average]
      end

      if flight.airplane_type.blank?
        unless flight.flight_info.nil?
          response[:airplane_type] = flight.flight_info.airplane
        end
      else
        response[:airplane_type] = flight.airplane_type
      end

      responses << response
    end
    responses
  end

  def get_call_sign(flight_number, airline_code)
    call_sign = flight_number.upcase.sub airline_code.upcase, airline_call_sign(airline_code)
  end

  private

  def to_dollar(amount)
    Currency.new.to_dollar amount
  end
end
