# frozen_string_literal: true

module En::SearchResultHelper
  def en_delay_to_human(delay)
    unless delay.nil?
      "<i class=\"warning circle yellow icon\"></i>  #{delay}m delay".html_safe
    end
  end

  def en_trip_duration_to_human(total_minute)
    message = ' '
    unless total_minute.nil?
      message = ' '
      hours = total_minute / 60
      minutes = total_minute % 60
      message = "#{hours} hours " unless hours == 0
      message += "and #{minutes} minutes " unless minutes == 0
    end
    message
  end

  def en_stop_to_human(stops)
    if stops.nil?
      message = 'Non-stop'
    else
      stops = stops.split(',')
      message = "#{stops.count} stop at "
      stops.each_with_index do |stop, index|
        message += ' and ' if index >= 1
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

  def en_day_name(date, saerch_parameter_date)
    date = date.to_date
    day_name = nil
    day_name = if date == Date.today
                 'today'
               elsif date == (Date.today + 1)
                 'tomorrow'
               else
                 date.strftime('%A')
               end
    (search_date_identifier(date, saerch_parameter_date) + day_name).html_safe
  end

  def en_price_to_human(price)
    message = if price.nil?
                "<i class='plane icon'></i>".html_safe
              else
                ('$' + price.to_s).html_safe
              end
    message
  end

  def en_hour_to_human(time)
    time_without_colon = time.to_s.tr(':', '')
    phrase = case time_without_colon.to_i
             when 400..1159 then 'morning'
             when 1200..1559 then 'noon'
             when 1600..1959 then 'evening'
             when 2000..2359 then 'night'
             when 0..359 then 'night'
             else
               ' '
         end
    time + ' ' + phrase
  end

  def en_airplane_name_for(airplane_type)
    case airplane_type.upcase
    when 'MD80', 'M82', 'MD-80', 'MD82', 'MD-82', 'MD83', 'MD-83', 'MD88', 'MD-88', 'MD.88', 'BOEING MD', 'MS'
      ariplane_name = 'Boeing MD'
    when 'AB3'
      ariplane_name = 'Airbus'
    when 'A300-600'
      ariplane_name = 'Airbus 300'
    when 'A310', 'AIRBUS A310'
      ariplane_name = 'Airbus 310'
    when 'A313', 'AIRBUS A313'
      ariplane_name = 'Airbus 313'
    when 'A319', 'AIRBUS A319'
      ariplane_name = 'Airbus 319'
    when 'A321', 'AIRBUS A321', 'AIRBUS 321'
      ariplane_name = 'Airbus 321'
    when 'A320', 'AIRBUS A320', '320', 'AIRBUS 320'
      ariplane_name = 'Airbus 320'
    when 'BOEING 727-200', '727', '727-200', 'B727', 'B.727', 'BOEING 727'
      ariplane_name = 'Boeing 727'
    when 'B737', '737', '737-500', 'B737-400', '737-300', '737-600', '737-300', '737-700', '737-100', 'BOEING 737'
      ariplane_name = 'Boeing 737'
    when 'FOKKER 100', 'F100', '100', 'FOKER'
      ariplane_name = 'Fokker 100'
    when '747'
      ariplane_name = 'Boeing 747'
    end

    ariplane_name ||= airplane_type
  end
end
