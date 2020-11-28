# frozen_string_literal: true

class Suppliers::Flightio < Suppliers::Base
  require 'open-uri'
  require 'uri'

  def register_request(origin, destination, date)
    get_flight_url = ENV['URL_FLIGHTIO_GET']
    date_time_string = date + 'T00:00:00'
    params = { "ADT": 1,
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
               ] }
    request_params = { "ValueObject": params.to_json.to_s }
    headers = { "Content-Type": 'application/json',
                "FUser": 'FlightioAppAndroid',
                "FApiVersion": '1.1',
                "FPass": 'Pw4FlightioAppAndroid' }
    response = Excon.post(get_flight_url,
                          body: request_params.to_json,
                          headers: headers,
                          proxy: Proxy.new_proxy)
    JSON.parse(response.body)
  end

  def search_supplier
    if Rails.env.test?
      response = File.read('test/fixtures/files/domestic-flightio.log')
      return { response: response, deeplink: 'http://flightio.com/fa/' }
    end

    begin
      request_id = register_request(origin, destination, date)['Data']
      search_flight_url = ENV['URL_FLIGHTIO_SEARCH'] + request_id
      deep_link = ENV['URL_FLIGHTIO_DEEPLINK'] + request_id + '&CombinationID='
      headers = { "FUser": 'FlightioAppAndroid', "FPass": 'Pw4FlightioAppAndroid' }
      response = Excon.get(search_flight_url, headers: headers, proxy: Proxy.new_proxy)
    rescue StandardError => e
      return { status: false }
    end
    { status: true, response: response.body, deeplink: deep_link }
  end

  def import_flights(response)
    flight_id = nil
    flight_id_list = nil
    flight_prices = []
    flight_ids = []
    doc = Nokogiri::HTML(response[:response])
    doc = doc.xpath('//div[@class="search-result flights-boxs depart flat-card "]')
    update_status search_history_id, "Extracting(#{Time.now.strftime('%M:%S')})"

    doc.each do |flight|
      price = flight['amount']
      airline_code = get_airline_code(flight['airline'].tr(',', ''))
      combination_id = flight['combinationid']
      deeplink_url = response[:deeplink] + combination_id
      departure_hour = flight['sourcedeparttime']

      departure_time_from = date + ' ' + departure_hour[0..1] + ':' + departure_hour[2..3] + ':00'
      departure_time_to = (departure_time_from.to_datetime + 0.04).strftime('%Y-%m-%d  %H:%M:%S').to_s

      ActiveRecord::Base.connection_pool.with_connection do
        flight_id_list = Flight.where(route_id: route_id).where(airline_code: airline_code.to_s).where(departure_time: departure_time_from.to_s..departure_time_to.to_s)
      end

      if flight_id_list.first.nil? # if true, then it means this flight is not available in our flight table
        next
      else
        flight_id = flight_id_list.first[:id]
      end

      flight_ids << flight_id

      # to prevent duplicate flight prices we compare flight prices before insert into database
      flight_price_so_far = flight_prices.select { |flight_price| flight_price.flight_id == flight_id }
      unless flight_price_so_far.empty? # check to see a flight price for given flight is exists
        if flight_price_so_far.first.price.to_i <= price.to_i # exist price is cheaper or equal to new price so ignore it
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

  def get_airline_code(airline_code)
    airlines = {
      'IS' => 'SR'
    }
    airlines[airline_code].nil? ? airline_code : airlines[airline_code]
  end
end
