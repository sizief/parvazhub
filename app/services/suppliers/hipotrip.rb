# frozen_string_literal: true

class Suppliers::Hipotrip < Suppliers::Base
  def get_params
    { "origin_destination": [{
      "origin": "AAP#{origin.upcase}",
      "destination": "AAP#{destination.upcase}",
      "date": date.to_s
    }],
      "adult": 1,
      "child": 0,
      "infant": 0,
      "flight_class": 'Y' }
  end

  def register_search
    url = ENV['URL_HIPO_GET']
    response = RestClient::Request.execute(method: :post,
                                               url: URI.parse(url).to_s,
                                               payload: get_params.to_json,
                                               proxy: nil,
                                               headers: { 'Content-Type': 'application/json' })
    JSON.parse response.body
  rescue StandardError => e
    update_status(e.message)
    raise 'first request error'
  end

  def search_supplier
    results = register_search

    request_id = results['request_id']
    url = ENV['URL_HIPO_SEARCH'] + request_id.to_s
    delay = results['estimated_delay_time'].to_f == 0 ? 5 : results['estimated_delay_time'].to_f
    sleep delay
    response = RestClient::Request.execute(method: :get,
                                               url: URI.parse(url).to_s,
                                               proxy: nil)
    response = response.body
    { status: true, response: response }
  rescue StandardError => e
    update_status(e.message)
    { status: false }
  end

  def import_flights(response)
    flight_id = nil
    flight_prices = []
    flight_ids = []
    json_response = JSON.parse(response[:response])
    request_id = json_response['request_id']

    json_response['flights'][0..ENV['MAX_NUMBER_FLIGHT'].to_i].each do |flight|
      leg_data = flight_id = nil
      leg_data = prepare flight['origin_destination'][0]['segments']

      next if leg_data.nil?
      next if leg_data[:airline_code].nil?
      next if leg_data[:airline_code] == ''
      next if leg_data[:airline_code].empty?

      ActiveRecord::Base.connection_pool.with_connection do
        flight_id = Flight.create_or_find_flight(route.id,
                                                 leg_data[:flight_number].join(','),
                                                 leg_data[:departure_date_time].first,
                                                 leg_data[:airline_code].join(','),
                                                 leg_data[:airplane_type].join(','),
                                                 leg_data[:arrival_date_time].last,
                                                 leg_data[:stop].join(','),
                                                 leg_data[:trip_duration])
      end
      flight_ids << flight_id

      price = flight['total_fare'][0]['total_price']
      price = (price / 10).to_i
      deeplink_url = get_deeplink request_id, flight['result_id']

      flight_price_so_far = flight_prices.select { |flight_price| flight_price.flight_id == flight_id }
      unless flight_price_so_far.empty?
        if flight_price_so_far.first.price.to_i <= price.to_i
          next
        else
          flight_price_so_far.first.price = price
          flight_price_so_far.first.deep_link = deeplink_url
          next
        end
      end

      flight_prices << FlightPrice.new(flight_id: flight_id.to_s, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink_url.to_s)
    end # end of each loop

    complete_import(flight_prices)
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
    flight_legs.each do |leg|
      airline_code = code_correction leg['airline']['iata']
      flight_number = airline_code + flight_number_correction(leg['airline']['flight_number'], airline_code)

      flight_numbers << flight_number
      airline_codes << airline_code
      airplane_types << leg['airline']['aircraft_hid']
      departure_date_times << leg['departure_datetime'].to_datetime
      arrival_date_times << leg['arrival_datetime'].to_datetime
      stops << leg['destination_airport_iata']
      trip_duration += to_minutes leg['duration']
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

  def code_correction(code)
    code = if code.upcase == 'SHI'
             'SR'
           elsif code.upcase == 'SH'
             'SE'
           else
             code
           end
    code
  end

  def to_minutes(time_string)
    total_time = 0
    time_string = time_string.split(':')
    total_time = time_string.first.to_i * 60
    total_time += time_string.second.to_i
  end

  def get_deeplink(request_id, result_id)
    ENV['URL_HIPO_DEEPLINK'] + "#{request_id}/#{result_id}"
  end

  def flight_number_correction(flight_number, airline_code)
    if flight_number.include? airline_code
      flight_number = flight_number.sub(airline_code, '')
    end
    flight_number.gsub(/[^\d,\.]/, '')
  end
  end
