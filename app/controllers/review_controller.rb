# frozen_string_literal: true

class ReviewController < ApplicationController
  def airline_reviews
    airline = Airline.find_by(english_name: params[:property_name])
    not_found if airline.nil?

    @airline_name = airline.persian_name
    @airline_code = airline.code
    @page = airline.english_name
    @rate_count = airline.rate_count
    @rate_average = airline.rate_average
    @rate_count ||= 0
    @rate_average ||= 0
    @reviews = Review.where(page: @page).where.not(text: '').where(published: true)
    @user = current_user
    @category = 'airline'
    @message = message
  end

  def supplier_reviews
    supplier = Supplier.where('lower(name) = ?', params[:property_name]).first
    not_found if supplier.nil?

    @supplier_persian_name = Supplier.new.get_persian_name supplier.name.downcase
    @supplier_english_name = supplier.name.downcase
    @page = supplier.name.downcase
    @rate_count = supplier.rate_count.nil? ? 0 : supplier.rate_count
    @rate_average = supplier.rate_average.nil? ? 0 : supplier.rate_average
    @reviews = Review.where(page: @page).where.not(text: '').where(published: true)
    @user = current_user
    @category = 'supplier'
    @message = message
  end

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  def create
    author = params[:author]
    rate = params[:rate]
    text = params[:text]
    page = params[:page]
    category = params[:category]
    channel = 'website'

    result = Reviews::Create.new(
      author: author,
      text: text,
      page: page,
      rate: rate,
      user: current_user,
      category: category
    ).call

    TelegramMonitoringWorker.perform_async("📣 #{page}, #{author}, #{text}, #{rate}")

    redirect_to action: "#{category}_reviews", property_name: page, review_saved: result
  end

  private

  def message
    return nil if params[:review_saved].nil?
    return success_message if params[:review_saved] == 'true'

    error_message
  end

  def success_message
    'دوست عزیز نظرتان ثبت شد. ممنونم که نظرتان را با ما و بقیه کاربران پروازهاب به اشتراک گذاشتید.'
  end

  def error_message
    'نظر شما به دلیل خطا ثبت نشد. سعی می‌کنیم خطا را بررسی و رفع کنیم. لطفا اگر مایل بودید درآینده دوباره تلاش کنید. ممنونیم.'
  end
end
