module ApplicationHelper
 
  def week_day_to_human_persian index
   days = ["یک‌شنبه","دوشنبه","سه‌شنبه","چهارشنبه","پنج‌شنبه","جمعه","شنبه"]
   return days[index]
  end

  def week_day_to_human_english index
    days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    return days[index]
   end

  def get_star_icon(total,amount,color,size)
    markup_delivery = " "
    markup_colored = "<i class=\"star icon #{color} #{size}\"></i>"
    markup = "<i class=\"grey star outline icon #{size}\"></i>"
    0.upto(amount-1) do
      markup_delivery += markup_colored
    end

    amount.upto(total-1) do
      markup_delivery += markup
    end

    return markup_delivery
  end

  def suppliers_list
    suppliers = Supplier.where(status: true)
  end

  def get_last_supplier_review
    Review.new.get_last_supplier_review
  end

  def get_last_airline_review
    Review.new.get_last_airline_review
  end

  def github_link
    if File.exist?("git_last_commit")
      json_data = File.read("git_last_commit")
      data = JSON.parse(json_data)
      text = "Last update: " + time_ago_in_words(data["date"].to_datetime) + " ago"
      link_to text, data["url"]
    end
  end

end
