# frozen_string_literal: true

module En::HomeHelper
  def tomorrow_price_by_dollar(route)
    flight = Flight.new.get_lowest_price(route, Date.today + 1)
    prepare_price_message_en flight
  end

  def en_title_by_route(route_id)
    route = Route.find(route_id)
    origin = City.find_by(city_code: route.origin).english_name.humanize
    destination = City.find_by(city_code: route.destination).english_name.humanize
    "#{origin} to #{destination}"
  end

  def en_flight_page_path_by_route(route_id, date)
    route = Route.find(route_id)
    origin = City.find_by(city_code: route.origin).english_name
    destination = City.find_by(city_code: route.destination).english_name
    en_flight_result_path(origin, destination, date)
  end

  private

  def prepare_price_message_en(flight)
    message = if flight.nil?
                'No seat available'
              else
                '$' + flight.best_price_dollar.to_s
              end
  end
end
