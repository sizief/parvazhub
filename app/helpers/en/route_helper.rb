module En::RouteHelper

  def en_dates_for_chart price_dates
    raw price_dates.map{|item| ((item[:date].to_date == Date.today)? "Today" : item[:date].to_date.strftime("%A %-d %B")) }
  end

end