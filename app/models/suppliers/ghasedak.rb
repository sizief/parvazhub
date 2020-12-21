# frozen_string_literal: true

class Suppliers::Ghasedak < Suppliers::Base
  require 'uri'
  require 'rest-client'

  def search_supplier
    url = ENV['URL_GHASEDAK_SEARCH']
    search_date = date.to_date.to_s.gsub('-', '/')
    params = "from=#{origin.upcase}&to=#{destination.upcase}&fromDate=#{search_date}&toDate=#{search_date}&userName=sepehr&password=1234&cs=1"


    response = RestClient::Request.execute(method: :get, url: URI.parse(url + params).to_s, proxy: nil, payload: params)
    { status: true, response: response.body }
#  rescue *HTTP_ERRORS => error
#    update_status(search_history_id, error.message)
#    { status: false }
  end

  def import_flights(response)
    flight_id = nil
    flight_prices = []
    flight_ids = []
    json_response = JSON.parse(response[:response])
    update_status(search_history_id, "Extracting(#{Time.now.strftime('%M:%S')})")

    json_response['data'].each do |flight|
      airline_code = get_airline_code(flight['Airline'])
      flight_number = airline_code + flight_number_correction(flight['FlightNo'], airline_code)
      departure_time = flight['FlightDate']
      departure_time = departure_time[0..9] + ' ' + departure_time[11..-1]

      airplane_type = flight['Airplane']
      ActiveRecord::Base.connection_pool.with_connection do
        flight_id = Flight.create_or_find_flight(route.id, flight_number, departure_time, airline_code, airplane_type)
      end
      flight_ids << flight_id

      price = flight['Price'].to_f / 10
      deeplink_url = flight['ReserveLink']

      # to prevent duplicate flight prices we compare flight prices before insert into database
      flight_price_so_far = flight_prices.select { |flight_price| flight_price.flight_id == flight_id }
      unless flight_price_so_far.empty? # check to see a flight price for given flight is exists
        if flight_price_so_far.first.price.to_i <= price.to_i # saved price is cheaper or equal to new price so we dont touch it
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
