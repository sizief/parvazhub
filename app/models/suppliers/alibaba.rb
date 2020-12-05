# frozen_string_literal: true

class Suppliers::Alibaba < Suppliers::Base
  require 'uri'
  require 'rest-client'

  URL = ENV['URL_ALIBABA']
  DEEPLINK = ENV['URL_ALIBABA_DEEPLINK']

  class RequestIdException < StandardError; end

  def search_supplier
    return dummy_data if Rails.env.test?

    token = request_id_token
    raise RequestIdException, 'request id for first request is not available' unless token

    { status: true, response: full_response(token) }
  rescue StandardError => e
    update_status(search_history_id, "failed:(#{Time.now.strftime('%M:%S')}) #{e.message}")
    { status: false }
  end

  private

  def full_response(token)
    flights = []
    is_completed = false
    timeout_for_alibaba = 0

    until is_completed
      response = RestClient.get(URL + token)
      result = JSON.parse(response)
      flights.push result['result']['departing']
      is_completed = result['result']['isCompleted']
      timeout_for_alibaba += 5
      break if ENV['TIMEOUT_DOMESTIC'].to_i <= timeout_for_alibaba
      sleep 5 unless is_completed
    end

    flights.flatten
  end

  def dummy_data
    # TODO: return Alibaba result
    { response: File.read('test/fixtures/files/domestic-ghasedak.log') }
  end

  def request_id_token
    res = RestClient.post(
      URL,
      request_id_params.to_json,
      { content_type: :json, accept: :json }
    )
    return false unless res

    JSON.parse(res)['result']['requestId'] if res
  rescue StandardError => e
    update_status(search_history_id, "failed:(#{Time.now.strftime('%M:%S')}) #{e.message}")
  end

  def request_id_params
    {
      adult: 1,
      child: 0,
      infant: 0,
      step: 'results',
      origin: origin,
      destination: destination,
      type: 'oneWay',
      departureDate: date,
      returnDate: nil
    }
  end

  def import_flights(response)
    flight_id = nil
    flight_prices = []
    flight_ids = []
    update_status(search_history_id, "Extracting(#{Time.now.strftime('%M:%S')})")

    response[:response].each do |flight|
      airline_code = flight['airlineCode']
      flight_number = airline_code + flight['flightNumber']
      departure_time = "#{flight['leaveDateTime'][0..9]} #{flight['leaveDateTime'][11..]}"

      airplane_type = flight['aircraft']
      ActiveRecord::Base.connection_pool.with_connection do
        flight_id = Flight.create_or_find_flight(route.id, flight_number, departure_time, airline_code, airplane_type)
      end
      flight_ids << flight_id

      price = flight['priceAdult'].to_f / 10
      deeplink_url = "#{DEEPLINK}#{origin.upcase}-#{destination.upcase}"
      deeplink_url += "?adult=1&child=0&infant=0&step=results&departing=#{date}&sort=leaveDateTime-asc"

      flight_price_so_far = flight_prices.select { |flight_price| flight_price.flight_id == flight_id }
      unless flight_price_so_far.empty?
        next if flight_price_so_far.first.price.to_i <= price.to_i

        flight_price_so_far.first.price = price
        flight_price_so_far.first.deep_link = deeplink_url
        next
      end
      flight_prices << FlightPrice.new(flight_id: flight_id.to_s, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink_url.to_s)
    end

    complete_import flight_prices, search_history_id
    flight_ids
  end
end
