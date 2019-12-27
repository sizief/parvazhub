# frozen_string_literal: true

class Suppliers::Trip < Suppliers::Base
  require 'uri'
  require 'rest-client'

  def send_request(_request_type, url, params)
    if Rails.env.test?
      return '{"success": true,"sid": "5a11518313fb7ae1cb2b4bb5"}'
    end

    begin
      response = RestClient::Request.execute(method: :post, url: URI.parse(url).to_s, payload: params.to_json, headers: { 'Content-Type': 'application/json' }, proxy: nil)
    rescue StandardError => e
      return nil
    end
    response.body
  end

  def register_request(origin, destination, date)
    params = {
      "src": origin.upcase,
      "isCityCodeSrc": true,
      "dst": destination.upcase,
      "isCityCodeDst": true,
      "class": 'e',
      "depDate": date,
      "retDate": '',
      "adt": 1,
      "chd": 0,
      "inf": 0
    }
    url = ENV['URL_TRIP_SEARCH']
    response = send_request('post', url, params)
    JSON.parse(response)
  end

  def is_search_complete(id)
    url = ENV['URL_TRIP_PROGRESS']
    response = if Rails.env.test?
                 '{"success": true,"val": 100}'
               else
                 send_request('post', url, "sid": id)
               end
    json_response = JSON.parse(response)
    is_complete = json_response['val'] == 100
  end

  def search_supplier
    search_id = register_request(origin, destination, date)['sid']
    url = ENV['URL_TRIP_RESULTS']
    params = {
      "sid": search_id,
      "itemPerPage": 1000
    }

    wait 25, search_id # seconds maximum

    if Rails.env.test?
      if Route.select(:international).find_by(origin: origin, destination: destination).international
        file = 'international-trip.log'
      else
        file = 'domestic-trip.log'
      end
      response = File.read('test/fixtures/files/' + file)
    else
      response = send_request('post', url, params)
    end

    raw_response = response.nil? ? { status: false } : { status: true, response: response }
    raw_response
  end

  def import_flights(response, route_id, _origin, _destination, date, search_history_id)
    flight_id = nil
    flight_prices = []
    flight_ids = []
    update_status(search_history_id, "Extracting(#{Time.now.strftime('%M:%S')})")
    response = JSON.parse(response[:response])

    response['flights'][0..ENV['MAX_NUMBER_FLIGHT'].to_i].each do |flight|
      leg_data = flight_id = nil
      leg_data = prepare flight['legs']
      price = flight['fares']['total']['price']
      id = flight['_id']
      deeplink_url = get_deep_link(id)

      next if leg_data.nil?

      stops = leg_data[:stop].empty? ? nil : leg_data[:stop].join(',')
      ActiveRecord::Base.connection_pool.with_connection do
        flight_id = Flight.create_or_find_flight(route_id,
                                                 leg_data[:flight_number].join(','),
                                                 leg_data[:departure_date_time].first,
                                                 leg_data[:airline_code].join(','),
                                                 leg_data[:airplane_type].join(','),
                                                 leg_data[:arrival_date_time].last,
                                                 stops,
                                                 leg_data[:trip_duration])
      end
      flight_ids << flight_id

      # to prevent duplicate flight prices we compare flight prices before insert into database
      flight_price_so_far = flight_prices.select { |flight_price| flight_price.flight_id == flight_id }
      unless flight_price_so_far.empty? # check to see a flight price for given flight is exists
        if flight_price_so_far.first.price.to_i <= price.to_i # saved price is cheaper or equal to new price so we dont touch it
          next
        else
          flight_price_so_far.first.price = price # new price is cheaper, so update the old price and go to next price
          flight_price_so_far.first.deep_link = deeplink_url
          next
        end
      end

      flight_prices << FlightPrice.new(flight_id: flight_id.to_s, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink_url.to_s)
    end # end of each loop

    complete_import flight_prices, search_history_id
    flight_ids
  end

  def prepare(flight_legs)
    flight_numbers = []
    airline_codes = []
    airplane_types = []
    departure_date_times = []
    arrival_date_times = []
    stops = []
    trip_duration = 0
    flight_legs.each_with_index do |leg, index|
      airline_code = get_airline_code(leg['operatorCode'])
      return nil if airline_code.nil?

      airline_codes << airline_code
      flight_numbers << airline_code + flight_number_correction(leg['flightNo'], airline_code)

      departure_date_time = leg['departureTime']
      departure_date_time += ':00' if departure_date_time.size == 16
      departure_date_times << departure_date_time.to_datetime

      arrival_date_time = leg['arrivalTime']
      arrival_date_time += ':00' if arrival_date_time.size == 16
      arrival_date_times << arrival_date_time.to_datetime

      unless flight_legs.count == index + 1
        stops << leg['arrivalAirport']
      end # we dont need last stops
      trip_duration += leg['duration']
    end

    trip_duration += calculate_stopover_duration(departure_date_times, arrival_date_times)
    { flight_number: flight_numbers,
      airline_code: airline_codes,
      airplane_type: airplane_types,
      departure_date_time: departure_date_times,
      arrival_date_time: arrival_date_times,
      stop: stops,
      trip_duration: trip_duration }
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

  def get_deep_link(_id)
    ENV['URL_TRIP_DEEPLINK']
  end

  def flight_number_correction(flight_number, airline_code)
    if flight_number.include? airline_code
      flight_number = flight_number.sub(airline_code, '')
    end
    flight_number.gsub(/[^\d,\.]/, '')
  end

  def get_airline_code(airline_code)
    airlines = {
      'RV' => 'IV',
      'SA' => 'SE',
      'ATR' => 'AK',
      'RZ' => 'SE',
      'IRZ' => 'SE',
      'ZZ' => 'SE'
    }
    airlines[airline_code].nil? ? airline_code : airlines[airline_code]
  end

  def wait(seconds, search_id)
    Timeout.timeout(seconds) do
      sleep 1 until is_search_complete(search_id)
    end
  rescue StandardError
  end
end
