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

    yesterday_name = ((Time.now.to_date-1).strftime '%A').downcase
    today_name = (Time.now.to_date.strftime '%A').downcase
    tomorrow_name = ((Time.now.to_date+1).strftime '%A').downcase

    if get_english_name(day) == yesterday_name
      return yesterday_datetime.to_datetime
    elsif get_english_name(day) == today_name
      return today_datetime.to_datetime
    else
      return tomorrow_datetime.to_datetime
    end
  end

  def get_english_name day
    case day
	  when "شنبه"
	  	en_day_name = "saturday"
    when "یکشنبه", "یک شنبه", "یک‌شنبه"
	  	en_day_name = "sunday"
    when "دوشنبه", "دو شنبه"
	  	en_day_name = "monday"
    when  "سهشنبه", "سه شنبه", "سه‌شنبه"
	  	en_day_name = "tuesday"
    when "چهارشنبه", "چهار شنبه"
	  	en_day_name = "wednesday"
    when "پنجشنبه", "پنج شنبه", "پنج‌شنبه"
	  	en_day_name = "thursday"
    when "جمعه"
	  	en_day_name = "friday"
    end
    return en_day_name
  end
  

end