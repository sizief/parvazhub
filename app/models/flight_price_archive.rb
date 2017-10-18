class FlightPriceArchive < ApplicationRecord
  has_many :redirect,
  :dependent => :restrict_with_exception

  def self.flight_price_over_time(flight_id,flight_date)
    price_time = Hash.new
    flight_prices = FlightPriceArchive.where(flight_id: flight_id, flight_date: flight_date).order(:created_at)
    flight_prices.each do |flight_price|
      flight_date = flight_price.created_at.to_date.to_s
      if price_time[flight_date.to_sym].nil?
        price_time[flight_date.to_sym] = flight_price.price
      else
        price_time[flight_date.to_sym] = flight_price.price if price_time[flight_date.to_sym] > flight_price.price
      end
    end
    return price_time

  end
end
