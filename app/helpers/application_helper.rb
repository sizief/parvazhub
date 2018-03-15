module ApplicationHelper
 
  def week_day_to_human_persian index
   days = ["یک‌شنبه","دوشنبه","سه‌شنبه","چهارشنبه","پنج‌شنبه","جمعه","شنبه"]
   return days[index]
  end

  def get_star_icon(total,amount,color,size)
    markup_delivery = " "
    markup_colored = "<i class=\"star icon #{color} #{size}\"></i>"
    markup = "<i class=\"empty grey star icon #{size}\"></i>"
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

  def eid_text index
    case index
      when 1
        "آرزوی سالی رنگی"
      when 2
        "آرزوی سالی سبز"
      when 3
        "آرزوی سالی گلی"
      when 4
        "آرزوی سالی سیبی"
      when 5
        "آرزوی سالی پر پول"
      when 6
        "آرزوی سالی گلی"
    end
  end


end
