# frozen_string_literal: true

class Suppliers::Trip < Suppliers::Base
  URL = ENV['URL_TRIP']
  DEEPLINK = ENV['URL_TRIP_DEEPLINK']

  def search_supplier
    response1 = RestClient::Request.execute(
      method: :post,
      url: URL,
      headers: headers,
      payload: params.to_json
    )
 
    search_id = JSON.parse(response1)['SearchId']
    sleep 1
    response2 = RestClient::Request.execute(
      method: :post,
      url: "#{URL}?searchId=#{search_id}",
      headers: headers,
      payload: params.to_json
    )

    { status: true, response: response2.body}
  rescue *HTTP_ERRORS => e
    update_status(e)
    { status: false }
  end

  def import_flights(response)
    flights = JSON.parse(response[:response])
    deeplink = "#{DEEPLINK}#{flights['SearchId']}"
    flights['Trips'].each do |flight|
      airline_code = airline_code_correction(
        flight['OutboundFlights'].first['MarketingAirline']['AirlineCode']
      )
      flight_number = flight_number_correction(
        flight['OutboundFlights'].first['FlightNumber'],
        airline_code
      )
      next if flight_number.nil?

      flight_number = airline_code + flight_number.to_s
      departure = "#{date} #{flight['OutboundFlights'].first['DepartsAt'][11..-2]}"
      airplane_type = flight['OutboundFlights'].first['Aircraft']
      price = flight['TotalPrice'].to_i

      saved_flight = Flight.upsert(route.id, flight_number, departure, airline_code, airplane_type)
      add_to_flight_prices(
        FlightPrice.new(flight_id: saved_flight.id, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink)
      )
    end
  end

  private

  def params
    dates = date.split('-')
    {
      OriginInformations:
        [
          {
            StrDepartDateTime: "#{dates.last}-#{dates[1]}-#{dates.first}",
            StrArriveDateTime: 'NaN-NaN-NaN',
            OriginAirport: origin.upcase,
            DestAirport: destination.upcase
          }
        ],
      NoOfAdults: '1',
      NoOfChilds: 0,
      NoOfInfants: 0,
      NearByAirport: false,
      IsInternal: false,
      OneWay: true,
      VendorExcludeCodes: [],
      VendorPreferenceCodes: [],
      CabinClassType: '100'
    }
  end

  def headers
    {
      'Content-Type': 'application/json; charset=UTF-8'
    }
  end
end
