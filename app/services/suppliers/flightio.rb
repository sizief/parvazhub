# frozen_string_literal: true

class Suppliers::Flightio < Suppliers::Base
  DEEPLINK = ENV['URL_FLIGHTIO_DEEPLINK']
  URL = ENV['URL_FLIGHTIO_GET']
  USERNAME = ENV['FLIGHTIO_USERNAME']
  PASSWORD = ENV['FLIGHTIO_PASSWORD']

  def register_request
    update_status("using proxy: #{proxy}") unless proxy.nil?
    JSON.parse(
      RestClient::Request.execute(
        method: :post,
        url: URL,
        proxy: nil,
        headers: headers,
        payload: { "ValueObject": params.to_json.to_s }.to_json
      ).body
    )
  rescue *HTTP_ERRORS => e
    update_status(e)
    nil
  end

  def search_supplier
    registered_request = register_request
    return { status: false } if registered_request.nil? || !registered_request['IsSuccessful']

    update_status("using proxy: #{proxy}") unless proxy.nil?
    request_id = registered_request['Data']
    deep_link = "#{DEEPLINK + request_id}&CombinationID="
    value = "/?value={%22FSL_Id%22:%22#{request_id}%22,%22PagingModel%22:{%22Page%22:1,%22Size%22:30,%22SortColumn%22:%22TotalChargeable%22,%22SortDirection%22:%220%22}}"
    response = RestClient::Request.execute(
      method: :get,
      url: URL + value,
      proxy: nil,
      headers: headers
    )
    { status: true, response: response.body, deeplink: deep_link }
  rescue *HTTP_ERRORS => e
    update_status(e)
    { status: false }
  end

  def import_flights(response)
    flight_id = nil

    JSON.parse(response[:response])['ResultModel']['ItemList'].each do |flight_item|
      flight = flight_item['Items'].first['Segments'].first
      airline_code = get_airline_code(flight['OperatingAirlineCode'])
      flight_number = airline_code + flight['FlightNumber']
      departure_time = "#{flight['DepartTime'][0..9]} #{flight['DepartTime'][11..]}"

      airplane_type = flight['AircraftName']
      ActiveRecord::Base.connection_pool.with_connection do
        flight_id = Flight.create_or_find_flight(route.id, flight_number, departure_time, airline_code, airplane_type)
      end

      price = flight_item['TotalChargeable'].to_f / 10
      deeplink_url = response[:deeplink] + flight_item['CombinationID']

      add_to_flight_prices(
        FlightPrice.new(flight_id: flight_id.to_s, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink_url.to_s)
      )
    end
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
      "FUser": USERNAME,
      "FPass": PASSWORD,
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

  def proxy
    @proxy ||= Proxy.fetch_path(supplier_name)
  end
end
