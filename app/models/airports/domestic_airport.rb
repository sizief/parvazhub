class Airports::DomesticAirport
  def convert_to_gregorian shamsi_date
    date = Parsi::DateTime.parse shamsi_date
    date = date.to_gregorian.to_date.to_s
    date += " "+shamsi_date[11..-1]
    date.to_datetime
  end

  def get_date_time(day,time)
    yesterday_datetime = (Time.now.to_date-1).to_s + " #{time}"
    today_datetime = (Time.now.to_date).to_s + " #{time}"
    tomorrow_datetime = (Time.now.to_date+1).to_s + " #{time}"

    yesterday_name = (Time.now.to_date-1).to_parsi.strftime '%A'
    today_name = Time.now.to_date.to_parsi.strftime '%A'
    tomorrow_name = (Time.now.to_date+1).to_parsi.strftime '%A'

    if day == yesterday_name
      return yesterday_datetime.to_datetime
    elsif day == today_name
      return today_datetime.to_datetime
    else
      return tomorrow_datetime.to_datetime
    end
  end

end