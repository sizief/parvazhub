# frozen_string_literal: true

module RouteHelper
  def dates_for_chart(price_dates)
    raw(
      price_dates.map do |item|
        item[:date].to_date == Date.today ? 'امروز' : JalaliDate.new(item[:date].to_date).strftime('%A %e %b').to_fa
      end
    )
  end

  def prices_for_chart(price_dates)
    price_dates.map { |item| (item[:price].nil? ? 0 : item[:price]) }
  end

  def date_price_is_empty(price_dates)
    prices = price_dates.map { |item| item[:price] }
    prices.compact.count < 2
  end

  def city_name(city_obj)
    city_obj.persian_name.nil? ? city_obj.english_name : city_obj.persian_name
  end
end
