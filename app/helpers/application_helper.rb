# frozen_string_literal: true

module ApplicationHelper
  def week_day_to_human_persian(index)
    days = ['یک‌شنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه', 'شنبه']
    days[index]
  end

  def week_day_to_human_english(index)
    days = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    days[index]
  end

  def get_star_icon(total, amount, color, size)
    markup_delivery = ' '
    markup_colored = "<i class=\"star icon #{color} #{size}\"></i>"
    markup = "<i class=\"grey star outline icon #{size}\"></i>"
    0.upto(amount - 1) do
      markup_delivery += markup_colored
    end

    amount.upto(total - 1) do
      markup_delivery += markup
    end

    markup_delivery
  end

  def suppliers_list
    Supplier.where(status: true)
  end

  def get_last_supplier_review
    Review.new.get_last_supplier_review
  end

  def get_last_airline_review
    Review.new.get_last_airline_review
  end

  def github_link
    return unless File.exist?('git_last_commit')

    json_data = File.read('git_last_commit')
    data = JSON.parse(json_data)
    "updated #{time_ago_in_words(data['date'].to_datetime)} ago"
  end
end
