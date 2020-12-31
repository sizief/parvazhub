# frozen_string_literal: true

module HomeHelper
  def tomorrow_price_by_rial(route)
    flight = Flight.new.get_lowest_price(route, Date.today + 1)
    prepare_price_message flight
  end

  def flight_page_path_by_route(route_id, date)
    route = Route.find(route_id)
    origin = City.find_by(city_code: route.origin).english_name
    destination = City.find_by(city_code: route.destination).english_name
    flight_result_path(origin, destination, date)
  end

  def persian_title_by_route(route_id)
    route = Route.find(route_id)
    origin = City.find_by(city_code: route.origin).persian_name
    destination = City.find_by(city_code: route.destination).persian_name
    "#{origin} به #{destination}"
  end

  private

  def prepare_price_message(flight)
    return '' if flight.nil?

    message = number_with_delimiter(flight.best_price).to_s.to_fa
    "#{message} تومان"
  end
end
