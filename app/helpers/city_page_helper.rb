module CityPageHelper

  def dates_for_chart price_dates
    raw price_dates.map{|item| item[:date].to_date.to_parsi.strftime "%-d %B" }
  end

  def prices_for_chart price_dates
    price_dates.map{|item| (item[:price].nil? ? 0 : item[:price])}
  end

  def date_price_is_empty price_dates
    prices = price_dates.map{|item| item[:price]}
    prices.compact.empty?
  end

end