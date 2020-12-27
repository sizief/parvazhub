# frozen_string_literal: true

module SearchHelper
  def airline_logo_for(airline_code, size = nil, is_block = true)
    image_url = 'airline-logos/' + airline_code[0..1] + '@2x.png'
    block = is_block ? ' ' : 'inline-block'
    if size.nil?
      image_tag(image_url, class: "airline-logo image ui #{block}")
    else
      image_tag(image_url, class: "airline-logo image ui #{block}", style: "width:#{size}")
    end
  end

  def supplier_logo_for(supplier, grayscale, size = nil)
    size ||= 'tiny'
    image_url = '/static/suppliers/' + supplier + '-logo.png'
    grayscale_class = grayscale ? 'grayscale' : ''
    image_tag image_url, class: "image ui supplier-logo #{size} flight-price-logo #{grayscale_class}"
  end

  def hour_to_human(time)
    time +
      case time.to_s.tr(':', '').to_i
      when 400..1159 then 'صبح'
      when 1200..1559 then 'ظهر'
      when 1600..1959 then 'عصر'
      when 2000..2359, 0..359 then 'شب'
      else ' '
      end
  end

  def hour_to_human_for_title(time)
    case time.to_s.tr(':', '').to_i
    when 400..1159 then 'صبح'
    when 1200..1559 then 'ظهر'
    when 1600..1959 then 'عصر'
    when 2000..2359, 0..359 then 'شب'
    else ''
    end
  end

  def search_link_builder(origin_name, destination_name, date)
    "/flights/#{origin_name}-#{destination_name}/#{date}"
  end

  def day_name_to_human(day)
    days_in_farsi = { today: 'امروز', tomorrow: 'فردا', dayaftertomorrow: 'پس فردا' }
    days_in_farsi[day]
  end

  def airline_name_for(airline)
    if airline.nil?
      ''
    else
      airline.persian_name.nil? ? airline.english_name : airline.persian_name
    end
  end

  def airplane_name_for(airplane_type)
    case airplane_type.upcase.delete(' ')
    when 'MCDOUGLASMD-80SERIES', 'MD', 'BOINGMD-82', 'BOEINGMD-82', 'BOEINGMD-88', 'MD80', 'M82', 'MD-80', 'MD82', 'MD-82', 'MD83', 'MD-83', 'MD88', 'MD-88', 'MD.88', 'BOEINGMD', 'MS', 'M83', 'M80'
      'بویینگ MD'
    when 'AB3'
      'ایرباس'
    when 'A300-600'
      'ایرباس ۳۰۰'
    when 'A310', 'AIRBUSA310', 'MED', 'AIRBUS310'
      'ایرباس ۳۱۰'
    when 'A313', 'AIRBUSA313'
      'ایرباس ۳۱۳'
    when 'A319', 'AIRBUSA319', '319'
      'ایرباس ۳۱۹'
    when 'A321', 'AIRBUSA321', 'AIRBUS321'
      'ایرباس ۳۲۱'
    when 'A320', 'AIRBUSA320', '320', 'AIRBUS320'
      'ایرباس ۳۲۰'
    when 'BOEING727-200', '727', '727-200', 'B727', 'B.727', 'BOEING727'
      'بویینگ ۷۲۷'
    when 'BOEING737(ALLSERIES-STAGE3)', 'B737', '737', '737-500', 'B737-400', '737-300', '737-600', '737-300', '737-700', '737-100', 'BOEING737'
      'بویینگ ۷۳۷'
    when 'FOKKER100', 'F100', '100', 'FOKER'
      'فوکر ۱۰۰'
    when '747'
      'بویینگ ۷۴۷'
    else
      airplane_type
    end
  end
end
