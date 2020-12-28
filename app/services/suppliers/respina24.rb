# frozen_string_literal: true

class Suppliers::Respina24 < Suppliers::Base
  URL = ENV['URL_RESPINA24_GET']

  def search_supplier
    response = RestClient::Request.execute(
      method: :get,
      url: URI.parse(URL + params).to_s,
      proxy: nil
    )
    { status: true, response: response.body }
  rescue *HTTP_ERRORS => e
    update_status(e.message)
    { status: false }
  end

  def import_flights(response)
    json_response = JSON.parse(response[:response])

    json_response['data'].each do |flight|
      airline_code = airline_code(flight['airlineCode'])
      flight_number = airline_code + flight['flightNumber']
      departure_time = "#{date} #{flight['takeoffTime']}:00"
      airplane_type = flight['flightName']
      price = flight['pricereal'].to_f / 10

      saved_flight = Flight.upsert(route.id, flight_number, departure_time, airline_code, airplane_type)
      add_to_flight_prices(
        FlightPrice.new(flight_id: saved_flight.id, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink_url)
      )
    end
  end

  def params
    "source[]=#{origin.upcase}&destination[]=#{destination.upcase}&DepartureGo=#{date}"
  end

  def airline_code(code)
    airlines = {
      '2' => 'W5',
      '9' => 'AK',
      '4' => 'B9',
      '8' => 'I3',
      '7' => 'JI',
      '12' => 'IV',
      '15' => 'SE',
      '6' => 'ZV',
      '10' => 'HH',
      '11' => 'QB',
      '1' => 'Y9',
      '5' => 'EP',
      '3' => 'IR',
      '14' => 'SR'
    }
    raise code if airlines[code].nil? && Rails.env.development?

    airlines[code]
  end
end
