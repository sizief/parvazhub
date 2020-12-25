# frozen_string_literal: true

class Suppliers::Safarme < Suppliers::Base
  @@api_site_id = ENV['URL_SAFARME_KEY']

  def get_params
    prepared_date = date.to_date.strftime '%Y/%m/%d'
    params = { 'From' => origin.upcase.to_s,
               'To' => destination.upcase.to_s,
               'Date' => prepared_date.to_s,
               'AdultCount' => 1,
               'ChildCount' => 0,
               'InfantCount' => 0,
               'CabinType' => 100,
               'ApiSiteID' => @@api_site_id }
  end

  def search_supplier
    url = ENV['URL_SAFARME_SEARCH']
    response = RestClient::Request.execute(method: :post,
                                               url: URI.parse(url).to_s,
                                               payload: get_params,
                                               proxy: nil)
    response = response.body
    { status: true, response: response }
  rescue StandardError => e
    update_status(e.message)
    return { status: false }
  end

  def prepare_response(response)
    response[0] = ''
    response[-1] = ''
    response.tr('\\', '')
  end

  def import_flights(response)
    flight_id = nil
    flight_prices = []
    flight_ids = []
    prepared_response = prepare_response(response[:response])
    json_response = JSON.parse(prepared_response)

    json_response[0..ENV['MAX_NUMBER_FLIGHT'].to_i].each do |flight|
      next if flight.nil?

      leg_data = flight_id = nil
      leg_data = prepare [flight]

      next if leg_data.nil?

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

      deeplink_url = get_deep_link(flight['FlightInDateID'], flight['SessionID'])
      price = (flight['Price'] / 10).to_i

      flight_price_so_far = flight_prices.select { |flight_price| flight_price.flight_id == flight_id }
      unless flight_price_so_far.empty?
        if flight_price_so_far.first.price.to_i <= price.to_i
          next
        else
          flight_price_so_far.first.price = price
          next
        end
      end

      flight_prices << FlightPrice.new(is_deep_link_url: false, flight_id: flight_id.to_s, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink_url.to_s)
    end # end of each loop

    complete_import(flight_prices)
    flight_ids
end

  def prepare(flight)
    flight_numbers = []
    airline_codes = []
    airplane_types = []
    departure_date_times = []
    arrival_date_times = []
    stops = []
    trip_duration = 0

    flight.each do |leg|
      airline_code = get_airline_code(leg['AirLineCode'])
      flight_number = airline_code + leg['TitleFlight'].delete('^0-9')

      flight_numbers << flight_number
      airline_codes << airline_code
      departure_date_times << date + ' ' + leg['StartTime']
      price = leg['Price'] / 10

      stops << nil
      airplane_types << nil
      arrival_date_times << nil
    end

    { flight_number: flight_numbers,
      airline_code: airline_codes,
      airplane_type: airplane_types,
      departure_date_time: departure_date_times,
      arrival_date_time: arrival_date_times,
      stop: stops,
      trip_duration: trip_duration }
  end

  def get_deep_link(flight_in_date_id, session_id)
    array_obj = []
    array_obj << { flight_in_date_id: flight_in_date_id, session_id: session_id }
    array_obj.to_json
  end

  def get_airline_code(airline_code)
    airlines = {
      '0' => 'SE',
      'SPN' => 'SR',
      'VR' => 'VA'
    }
    airlines[airline_code].nil? ? airline_code : airlines[airline_code]
  end

  def self.create_deep_link(data)
    url = ENV['URL_SAFARME_DEEPLINK']
    json_data = JSON.parse(data)[0]
    params = { 'SessionId' => json_data['session_id'],
               'FlightInDateId' => json_data['flight_in_date_id'],
               'ApiSiteId' => @@api_site_id,
               'ReturnFlightInDateId' => nil }
    response = RestClient::Request.execute(method: :post,
                                           url: URI.parse(url).to_s,
                                           payload: params,
                                           proxy: nil)
    response.body.tr('"', '')
  end
end
