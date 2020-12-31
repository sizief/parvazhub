# frozen_string_literal: true

module SearchResultHelper
  def delay_to_human(delay)
    unless delay.nil?
      "<i class=\"warning circle yellow icon\"></i>احتمال  #{delay} دقیقه تاخیر".html_safe
    end
  end

  def trip_duration_to_human(total_minute)
    message = ' '
    unless total_minute.nil?
      message = ' '
      hours = total_minute / 60
      minutes = total_minute % 60
      message = "#{hours} ساعت " unless hours == 0
      message += "و #{minutes} دقیقه " unless minutes == 0
    end
    message
  end

  def stop_to_human(stops)
    if stops.nil?
      message = 'بدون توقف'
    else
      stops = stops.split(',')
      message = "#{stops.count} توقف در "
      stops.each_with_index do |stop, index|
        message += ' و ' if index >= 1
        message += stop
      end
    end
    message
  end

  def number_with_zero(number)
    number_string = number.to_s
    case number_string.size
    when 5
      number_with_zero = '000' + number_string
    when 6
      number_with_zero = '00' + number_string
    when 7
      number_with_zero = '0' + number_string
    when 8
      number_with_zero = number_string
    end
    number_with_zero
  end

  def day_name(date, search_parameter_date)
    date = date.to_date
    day_name = nil
    day_name = if date == Date.today
                 'امروز'
               elsif date == (Date.today + 1)
                 'فردا'
               else
                 JalaliDate.new(date).strftime('%A')
               end
    (search_date_identifier(date, search_parameter_date) + day_name).html_safe
  end

  def search_date_identifier(date, saerch_parameter_date)
    if saerch_parameter_date.to_date == date.to_date
      "<i class='arrow down icon'></i>"
    else
      ''
    end
  end

  def price_to_human(price)
    return "<i class='plane icon'></i>".html_safe if price.nil?

    "#{(price / 1000).to_s.to_fa} <sup><span style='font-size:0.5em'>هزارتومان</span></sup>".html_safe
  end
end
