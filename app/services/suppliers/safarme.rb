# frozen_string_literal: true

class Suppliers::Safarme < Suppliers::Base
  API_SITE_ID = ENV['URL_SAFARME_KEY']
  URL = ENV['URL_SAFARME_SEARCH']
  DEEPLINK = ENV['URL_SAFARME_DEEPLINK']

  def params
    prepared_date = date.to_date.strftime '%Y/%m/%d'
    {
      'From' => origin.upcase.to_s,
      'To' => destination.upcase.to_s,
      'Date' => prepared_date.to_s,
      'AdultCount' => 1,
      'ChildCount' => 0,
      'InfantCount' => 0,
      'CabinType' => 100,
      'ApiSiteID' => API_SITE_ID
    }
  end

  def search_supplier
    response = RestClient::Request.execute(
      method: :post,
      url: URI.parse(URL).to_s,
      payload: params
    )
    { status: true, response: response.body }
  rescue *HTTP_ERRORS => e
    update_status(e)
    { status: false }
  end

  def prepare_response(response)
    response[0] = ''
    response[-1] = ''
    response.tr('\\', '')
  end

  def import_flights(response)
    prepared_response = prepare_response(response[:response])
    json_response = JSON.parse(prepared_response)

    json_response[0..ENV['MAX_NUMBER_FLIGHT'].to_i].each do |legs|
      next if legs.nil?

      flight = legs.first
      airline_code = airline_code(flight['AirLineCode'])
      flight_number = airline_code + flight['TitleFlight'].delete('^0-9')
      departure_time = "#{date}  #{flight['StartTime']}"
      price = filght['Price'] / 10
      airplane_type = nil

      saved_flight = Flight.upsert(route.id, flight_number, departure_time, airline_code, airplane_type)
      add_to_flight_prices(
        FlightPrice.new(flight_id: saved_flight.id, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink_url)
      )
    end
  end

  def airline_code(code)
    airlines = {
      '0' => 'SE',
      'SPN' => 'SR',
      'VR' => 'VA'
    }
    airlines[code].nil? ? code : airlines[code]
  end
end
