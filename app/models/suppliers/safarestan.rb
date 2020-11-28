# frozen_string_literal: true

class Suppliers::Safarestan < Suppliers::Base
  require 'uri'
  require 'rest-client'
  require 'rbzip2'

  def get_params
    { "apikey": ENV['URL_SAFARESTAN_KEY'],
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
      "deviceInfo": {} }
  end

  def search_supplier
    begin
      url = ENV['URL_SAFARESTAN_SEARCH']
      if Rails.env.test?
        response = mock_results
      else
        response = RestClient::Request.execute(method: :post,
                                               url: URI.parse(url).to_s,
                                               payload: get_params.to_json,
                                               proxy: nil)
        response = response.body
      end
    rescue StandardError => e
      update_status(search_history_id, "failed:(#{Time.now.strftime('%M:%S')}) #{e.message}")
      return { status: false }
    end
    { status: true, response: response }
  end

  def import_flights(response)
    flight_id = nil
    flight_prices = []
    flight_ids = []
    update_status(search_history_id, "Extracting(#{Time.now.strftime('%M:%S')})")

    json_response = decode(JSON.parse(response[:response]))
    json_response[0..ENV['MAX_NUMBER_FLIGHT'].to_i].each do |flight|
      leg_data = flight_id = nil
      leg_data = prepare flight
      flight_id = find_flight_id leg_data, route.id

      next if leg_data.nil? || flight_id.nil?

      flight_ids << flight_id

      price = (flight['singleAdultFinalPrice'] / 10).to_i
      deeplink_url = get_deeplink

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

    private

  def find_flight_id(leg_data, route_id)
    flights = nil
    flight_id = nil
    departure_time_from = (leg_data[:departure_date_time]).strftime('%Y-%m-%d  %H:%M:%S').to_s
    departure_time_to = (leg_data[:departure_date_time] + 0.04).strftime('%Y-%m-%d  %H:%M:%S').to_s
    ActiveRecord::Base.connection_pool.with_connection do
      flights = Flight.where(route_id: route_id).where(airline_code: leg_data[:airline_code]).where(departure_time: departure_time_from.to_s..departure_time_to.to_s)
    end

    flight_id = flights.first[:id] unless flights.empty?
  end

  def decode(response)
    if response['result']['compressed']
      temp = Base64.decode64 response['result']['products']
      response = RBzip2.default_adapter::Decompressor.new(StringIO.new(temp.to_s))
      response = JSON.parse response.read
    else
      response = response['result']['products']
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

  def get_deeplink
    'https://www.safarestan.com/'
  end
  end
