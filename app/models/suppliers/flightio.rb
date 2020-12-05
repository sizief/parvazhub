# frozen_string_literal: true

class Suppliers::Flightio < Suppliers::Base
  require 'open-uri'
  require 'uri'

  def register_request
    JSON.parse(
      Excon.post(
        ENV['URL_FLIGHTIO_GET'],
        body: { "ValueObject": params.to_json.to_s }.to_json,
        headers: headers
      ).body
    )
  end

  def search_supplier
    if Rails.env.test?
      response = File.read('test/fixtures/files/domestic-flightio.log')
      return { response: response, deeplink: 'http://flightio.com/fa/' }
    end

    begin
      request_id = register_request['Data']
      deep_link = ENV['URL_FLIGHTIO_DEEPLINK'] + request_id + '&CombinationID='
      value = "/?value={%22FSL_Id%22:%22#{request_id}%22,%22PagingModel%22:{%22Page%22:1,%22Size%22:30,%22SortColumn%22:%22TotalChargeable%22,%22SortDirection%22:%220%22}}"
      response = Excon.get(ENV['URL_FLIGHTIO_GET'] + value, headers: headers)
    rescue StandardError
      return { status: false }
    end
    { status: true, response: response.body, deeplink: deep_link }
  end

  def import_flights(response)
    flight_id = nil
    flight_prices = []
    flight_ids = []
    update_status search_history_id, "Extracting(#{Time.now.strftime('%M:%S')})"

    JSON.parse(response[:response])['ResultModel']['ItemList'].each do |flight_item|
      flight = flight_item['Items'].first["Segments"].first
      airline_code = get_airline_code(flight['OperatingAirlineCode'])
      flight_number = airline_code + flight['FlightNumber']
      departure_time = "#{flight['DepartTime'][0..9]} #{flight['DepartTime'][11..]}"

      airplane_type = flight['AircraftName']
      ActiveRecord::Base.connection_pool.with_connection do
        flight_id = Flight.create_or_find_flight(route.id, flight_number, departure_time, airline_code, airplane_type)
      end
      flight_ids << flight_id

      price = flight_item['TotalChargeable'].to_f / 10
      deeplink_url = response[:deeplink] + flight_item['CombinationID']

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

  def get_airline_code(airline_code)
    airlines = {
      'RV' => 'IV',
      'IS' => 'SR'
    }
    airlines[airline_code].nil? ? airline_code : airlines[airline_code]
  end

  def params
    date_time_string = "#{date}T00:00:00"
    {
      "ADT": 1,
      "CHD": 0,
      "INF": 0,
      "CabinType": '1',
      "flightType": '2',
      "tripMode": '1',
      "DestinationInformationList": [
        {
          "DepartureDate": date_time_string.to_s,
          "DestinationLocationAirPortCode": destination.upcase.to_s,
          "DestinationLocationAllAirport": true,
          "DestinationLocationCityCode": destination.upcase.to_s,
          "Index": 1,
          "OriginLocationAirPortCode": origin.upcase.to_s,
          "OriginLocationAllAirport": true,
          "OriginLocationCityCode": origin.upcase.to_s
        }
      ]
    }
  end

  def headers
    {
      "FUser": 'FlightioAppAndroid',
      "FPass": 'Pw4FlightioAppAndroid',
      "FApiVersion": '1.1',
      "Content-Type": 'application/json'
      # "FSession": '078ee89c-0cdd-43c8-b414-a4fe1113079a',
      # "Host": 'api.flightio.com',
      # "User-Agent": 'Dalvik/2.1.0 (Linux; U; Android 10; E6883 Build/QQ3A.200805.001)',
      # "Content-Type": 'application/json; charset=UTF-8',
      # "connection": 'close',
      # "Accept-Encoding": 'gzip'
    }
  end
end
