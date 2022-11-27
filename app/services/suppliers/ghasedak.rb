# frozen_string_literal: true

class Suppliers::Ghasedak < Suppliers::Base
  URL = ENV['URL_GHASEDAK_SEARCH']

  def search_supplier
    response = RestClient.post(
      URL,
      {date: date, number: '1-0-0', route: "#{origin.upcase}-#{destination.upcase}"}.to_json,
      { content_type: :json, accept: :json }
    )
    { status: true, response: response.body }
  rescue *HTTP_ERRORS => e
  rescue OpenSSL::SSL::SSLError => e
  rescue RestClient::SSLCertificateNotVerified => e
    update_status(e.message)
    { status: false }
  end


  def import_flights(response)
    json_response = JSON.parse(response[:response])

    json_response['search']['flights'].each do |flight|
      airline_code = airline_code_correction(flight['airline_code'])
      flight_number = airline_code + flight_number_correction(flight['flight_no'], airline_code)
      departure_time = flight['departure_iso_datetime']
      departure_time = departure_time[0..9] + ' ' + departure_time[11..-1]
      price = flight['price']
      deeplink_url = "https://ghasedak24.com/reservation/entries/#{flight['ticket_id']}/?adl=1&chd=0&inf=0&fr=0"

      saved_flight = Flight.upsert(route.id, flight_number, departure_time, airline_code, nil)
      add_to_flight_prices(
        FlightPrice.new(flight_id: saved_flight.id, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink_url)
      )
    end
  end
end
