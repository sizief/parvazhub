# frozen_string_literal: true

require 'rbzip2'

class Suppliers::Safarestan < Suppliers::Base
  URL = ENV['URL_SAFARESTAN_SEARCH']
  DEEPLINK = 'https://www.safarestan.com/'

  def search_supplier
    response = RestClient::Request.execute(
      method: :post,
      url: URI.parse(URL).to_s,
      payload: params.to_json,
      proxy: nil
    )
    { status: true, response: response.body }
  rescue *HTTP_ERRORS => e
    update_status(e.message)
    { status: false }
  end

  def import_flights(response)
    flight_id = nil
    json_response = decode(JSON.parse(response[:response]))

    json_response[0..ENV['MAX_NUMBER_FLIGHT'].to_i].each do |flight|
      leg_data = prepare flight
      flight_id = find_flight_id leg_data, route.id

      next if leg_data.nil? || flight_id.nil?

      price = (flight['singleAdultFinalPrice'] / 10).to_i

      add_to_flight_prices(
        FlightPrice.new(flight_id: flight_id.to_s, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: DEEPLINK)
      )
    end
  end

  private

  def find_flight_id(leg_data, route_id)
    flights = nil
    departure_time_from = (leg_data[:departure_date_time]).strftime('%Y-%m-%d  %H:%M:%S').to_s
    departure_time_to = (leg_data[:departure_date_time] + 0.04).strftime('%Y-%m-%d  %H:%M:%S').to_s
    ActiveRecord::Base.connection_pool.with_connection do
      flights = Flight.where(route_id: route_id).where(airline_code: leg_data[:airline_code]).where(departure_time: departure_time_from.to_s..departure_time_to.to_s)
    end

    flights.first[:id] unless flights.empty?
  end

  def decode(response)
    if response['result']['compressed']
      temp = Base64.decode64 response['result']['products']
      response = RBzip2.default_adapter::Decompressor.new(StringIO.new(temp.to_s))
      JSON.parse response.read
    else
      response['result']['products']
    end
  end

  def prepare(leg)
    {
      airline_code: leg['airlineCode'],
      departure_date_time: leg['departureTime'].to_datetime,
      arrival_date_time: leg['arrivalTime'].to_datetime,
      trip_duration: leg['duration']
    }
  end

  def params
    {
      "apikey": ENV['URL_SAFARESTAN_KEY'],
      "uid": '',
      "clientVersion": 4,
      "productType": 'localFlight',
      "searchFilter": {
        "sourceAirportCode": origin.upcase.to_s,
        "targetAirportCode": destination.upcase.to_s,
        "sourceAllinFromCity": true,
        "targetAllinFromCity": true,
        "leaveDate": date,
        "adultCount": 1,
        "childCount": 0,
        "infantCount": 0,
        "oneWay": true,
        "productType": 'localFlight',
        "compressed": true,
        "expireTime": 0,
        "validTimeout": 0,
        "isNew": true
      },
      "deviceInfo": {}
    }
  end
end
