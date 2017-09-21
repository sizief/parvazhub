module ApplicationHelper
 
    def week_day_to_human_persian index
   days = ["","دوشنبه","سه‌شنبه","چهارشنبه","پنج‌شنبه","جمعه","شنبه","یک‌شنبه"]
   return days[index]
 end

end
