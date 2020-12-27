# frozen_string_literal: true

class Suppliers::Ghasedak < Suppliers::Base
  URL = ENV['URL_GHASEDAK_SEARCH']

  def search_supplier
    response = RestClient::Request.execute(
      method: :get,
      url: URI.parse(URL + params).to_s,
      proxy: nil,
      payload: params
    )
    { status: true, response: response.body }
  rescue *HTTP_ERRORS => e
    update_status(e.message)
    { status: false }
  end

  def params
    search_date = date.to_date.to_s.gsub('-', '/')
    "from=#{origin.upcase}&to=#{destination.upcase}&fromDate=#{search_date}&toDate=#{search_date}&userName=sepehr&password=1234&cs=1"
  end

  def import_flights(response)
    flight_id = nil
    json_response = JSON.parse(response[:response])

    json_response['data'].each do |flight|
      airline_code = get_airline_code(flight['Airline'])
      flight_number = airline_code + flight_number_correction(flight['FlightNo'], airline_code)
      departure_time = flight['FlightDate']
      departure_time = departure_time[0..9] + ' ' + departure_time[11..-1]

      airplane_type = flight['Airplane']
      ActiveRecord::Base.connection_pool.with_connection do
        flight_id = Flight.create_or_find_flight(route.id, flight_number, departure_time, airline_code, airplane_type)
      end

      price = flight['Price'].to_f / 10
      deeplink_url = flight['ReserveLink']

      add_to_flight_prices(
        FlightPrice.new(flight_id: flight_id.to_s, price: price.to_s, supplier: supplier_name.downcase, flight_date: date.to_s, deep_link: deeplink_url.to_s)
      )
    end
  end

  def get_airline_code(airline_code)
    airlines = {
      'RV' => 'IV',
      'ZZ' => 'SR',
      'RZ' => 'SR',
      'IS' => 'SR',
      'SE' => 'SR'
    }
    airlines[airline_code].nil? ? airline_code : airlines[airline_code]
  end

  def flight_number_correction(flight_number, airline_code)
    if flight_number.include? airline_code
      flight_number = flight_number.sub(airline_code, '')
    end
    flight_number.gsub(/[^\d,\.]/, '')
  end
end
