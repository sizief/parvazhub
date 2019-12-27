# frozen_string_literal: true

module En::FlightPriceHelper
  def hour_to_human_for_en_title(time)
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
    phrase
  end

  def english_airline_name_for(airline)
    name = if airline.nil?
             ''
           else
             airline.english_name.sub('-', ' ').humanize
           end
    name
  end
end
