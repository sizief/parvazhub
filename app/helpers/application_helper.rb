module ApplicationHelper
 
  def week_day_to_human_persian index
   days = ["یک‌شنبه","دوشنبه","سه‌شنبه","چهارشنبه","پنج‌شنبه","جمعه","شنبه"]
   return days[index]
  end

end
