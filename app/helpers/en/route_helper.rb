module En::RouteHelper

  def en_dates_for_chart price_dates
    raw price_dates.map{|item| ((item[:date].to_date == Date.today)? "Today" : item[:date].to_date.strftime("%A %-d %B")) }
  end

  def en_prices_for_chart price_dates
    price_dates.map{|item| (item[:price_dollar].nil? ? 0 : item[:price_dollar])}
  end

end