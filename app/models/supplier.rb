# frozen_string_literal: true

class Supplier < ApplicationRecord
  validates :name, uniqueness: true

  def get_persian_name(supplier_name)
    case supplier_name
    when 'zoraq'
      'زورق'
    when 'alibaba'
      'علی‌بابا'
    when 'safarme'
      'سفرمی'
    when 'flightio'
      'فلایتیو'
    when 'ghasedak'
      'قاصدک۲۴'
    when 'respina'
      'رسپینا۲۴'
    when 'trip'
      'تریپ'
    when 'travelchi'
      'تراولچی'
    when 'iranhrc'
      'ایران‌اچ‌آر‌سی'
    when 'sepehr'
      'سپهرسیر'
    when 'flytoday'
      'فلای‌تودی'
    when 'safarestan'
      'سفرستان'
    when 'hipotrip'
      'هیپوتریپ'
    when 'snapptrip'
      'اسنپ‌تریپ'
    else
      supplier_name
    end
  end

  def get_logo(supplier_name)
    'https://parvazhub.com/static/suppliers/' + supplier_name.to_s + '-logo.png'
  end

  def update_rates
    Supplier.all.each do |supplier|
      rate_sum = Review.where(page: supplier.name.downcase).sum('rate')
      rate_count = Review.where(page: supplier.name.downcase).where.not(rate: nil).count
      rate_average = rate_count == 0 ? 0 : (rate_sum.to_f / rate_count).round

      supplier.rate_average = rate_average
      supplier.rate_count = rate_count
      supplier.save
    end
  end

  def get_active_suppliers
    Supplier.where(status: true)
  end
end
