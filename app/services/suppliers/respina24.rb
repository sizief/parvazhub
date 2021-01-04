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
      airline_code = airline_code_correction(airline_code(flight['airlineCode']))
      next if airline_code.nil?

      flight_number = airline_code + flight['flightNumber']
      departure_time = "#{date} #{flight['takeoffTime']}:00"
      airplane_type = flight['flightName']
      price = flight['pricereal'].to_f / 10
      next if price.nil? || price.zero?
      next if price == 1000_000 # it means it is soldout :shrug:

      origin_in_persian = City.find_by(city_code: origin.downcase).persian_name
      destination_in_persian = City.find_by(city_code: destination.downcase).persian_name
      deeplink = "https://respina24.ir/flight/search/#{origin.upcase}/#{destination.upcase}/بلیط-هواپیما-#{origin_in_persian}-#{destination_in_persian}?date=#{date}"

      saved_flight = Flight.upsert(route.id, flight_number, departure_time, airline_code, airplane_type)
      add_to_flight_prices(
        FlightPrice.new(flight_id: saved_flight.id, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink)
      )
    end
  end

  def params
    "source[]=#{origin.upcase}&destination[]=#{destination.upcase}&DepartureGo=#{date}"
  end

  def airline_code(code)
    case code
    when 2
      'W5'
    when 9
      'AK'
    when 4
      'B9'
    when 8
      'I3'
    when 7
      'JI'
    when 12
      'IV'
    when 15
      'SE'
    when 6
      'ZV'
    when 10
      'HH'
    when 11
      'QB'
    when 1
      'Y9'
    when 5
      'EP'
    when 3
      'IR'
    when 14
      'SR'
    when 29
      'VR'
    end
  end
end
