# frozen_string_literal: true

class Suppliers::Alibaba < Suppliers::Base
  URL = ENV['URL_ALIBABA']
  DEEPLINK = ENV['URL_ALIBABA_DEEPLINK']

  class RequestIdException < StandardError; end

  def search_supplier
    token = request_id_token
    raise RequestIdException, 'request id for first request is not available' unless token

    { status: true, response: full_response(token) }
  rescue *HTTP_ERRORS => e
    update_status(e.message)
    { status: false }
  end

  def import_flights(response)
    response[:response].each do |flight|
      airline_code = flight['airlineCode']
      flight_number = airline_code + flight['flightNumber']
      departure_time = "#{flight['leaveDateTime'][0..9]} #{flight['leaveDateTime'][11..]}"
      airplane_type = flight['aircraft']
      price = flight['priceAdult'].to_f / 10
      deeplink_url = "#{DEEPLINK}#{origin.upcase}-#{destination.upcase}"
      deeplink_url += "?adult=1&child=0&infant=0&step=results&departing=#{date}&sort=leaveDateTime-asc"

      saved_flight = Flight.upsert(route.id, flight_number, departure_time, airline_code, airplane_type)
      add_to_flight_prices(
        FlightPrice.new(flight_id: saved_flight.id, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink_url)
      )
    end
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

  def request_id_token
    res = RestClient.post(
      URL,
      request_id_params.to_json,
      { content_type: :json, accept: :json }
    )
    return false unless res

    JSON.parse(res)['result']['requestId'] if res
  rescue *HTTP_ERRORS => e
    update_status(e.message)
    false
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
end
