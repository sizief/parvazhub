# frozen_string_literal: true

class Suppliers::Snapptrip < Suppliers::Base
  URL = ENV['URL_SNAPPTRIP_GET']

  def search_supplier
    response = RestClient::Request.execute(
      method: :post,
      url: URL,
      proxy: nil,
      headers: headers,
      payload: params.to_json
    )
    { status: true, response: ActiveSupport::Gzip.decompress(response.body) }
  rescue *HTTP_ERRORS => e
  rescue RestClient::BadRequest => e
  rescue RestClient::InternalServerError => e
  rescue RestClient::Found => e
  rescue RestClient::NotFound => e
  rescue RestClient::Found => e
  rescue RestClient::Found => e
  rescue RestClient::InternalServerError => e
    update_status(e)
    { status: false }
  end

  def import_flights(response)
    JSON.parse(response[:response]).first['solutions'].each do |flight|
      airline_code = airline_code_correction(flight['airline']['code'])
      flight_number = flight['flightNumber'].to_i
      next if flight_number.zero?

      flight_number = airline_code + flight_number.to_s
      departure = flight['departure']
      airplane_type = flight['legs'].first['details'].first['aircraft']
      price = flight['totalPrice']['amount'].to_f / 10
      deeplink_url = "https://www.snapptrip.com/flights/#{origin.upcase}/#{destination.upcase}?roundTrip=false&adultCount=1&childCount=0&inLapCount=0&date=#{date}&cabinType=E"

      saved_flight = Flight.upsert(route.id, flight_number, departure, airline_code, airplane_type)
      add_to_flight_prices(
        FlightPrice.new(flight_id: saved_flight.id, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink_url)
      )
    end
  end

  private

  def secret
    data = ":#{params.to_json.downcase}"
    sign = "post:#{data}:#{guid}".strip
    encoded = Base64.strict_encode64(sign).gsub '=', ''
    sha = OpenSSL::HMAC.hexdigest('SHA256', 'function', encoded)
    "Bearer #{sha}.#{guid}"
  end

  def guid
    @guid ||= ExecJS.eval("'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g,(function(e){var t=16*Math.random()|0;return('x'==e?t:3&t|8).toString(16)}))")
  end

  def params
    {
      origin: origin.upcase,
      destination: destination.upcase,
      roundTrip: false,
      passengers:
        {
          adults: 1,
          children: 0,
          infants: 0
        },
      cabinType: 'E',
      departDate: date
    }
  end

  def headers
    {
      'X-Request-Id': secret,
      'Host': 'www.snapptrip.com',
      'Content-Type': 'application/json; charset=UTF-8',
      'User-Agent': 'Dalvik/2.1.0 (Linux; U; Android 10; E6883 Build/QQ3A.200805.001)',
      'Connection': 'keep-alive',
      'Accept-Encoding': 'gzip, deflate, br',
      'Accept': '*/*'
    }
  end
end
