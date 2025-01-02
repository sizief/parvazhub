# frozen_string_literal: true

class ReviewController < ApplicationController
  def airline_reviews
    airline = Airline.find_by(english_name: params[:property_name])
    raise ActionController::RoutingError, 'Not Found' if airline.nil?

    @page_name = airline.persian_name
    @airline_code = airline.code
    @page = airline.english_name
    @rate_count = airline.rate_count
    @rate_average = airline.rate_average
    @rate_count ||= 0
    @rate_average ||= 0
    @category = 'airline'
    common_variables
  end

  def supplier_reviews
    supplier = Supplier.where('lower(name) = ?', params[:property_name]).first
    raise ActionController::RoutingError, 'Not Found' if supplier.nil?

    @page_name = Supplier.new.get_persian_name supplier.name.downcase
    @supplier_english_name = supplier.name.downcase
    @page = supplier.name.downcase
    @rate_count = supplier.rate_count.nil? ? 0 : supplier.rate_count
    @rate_average = supplier.rate_average.nil? ? 0 : supplier.rate_average
    @category = 'supplier'
    common_variables
  end

  def create
    return nil if create_params[:text] =~ /dark|web|drug|onion|tor|market|iq/
    return nil if !create_params[:text].scan(/\p{Cyrillic}/).empty? #Block Russian spams

    result = Reviews::Create.new(
      author: create_params[:author],
      text: create_params[:text],
      page: create_params[:page],
      rate: create_params[:rate],
      user: current_user,
      category: create_params[:category]
    ).call

    TelegramMonitoringWorker.perform_async("📣 #{create_params[:author]}, #{create_params[:text]}")
    redirect_to action: "#{create_params[:category]}_reviews", property_name: create_params[:page], review_saved: result
  end

  private

  def common_variables
    @reviews = Review
      .where(page: @page)
      .where.not(text: '')
      .where(published: true)
      .includes(:user)
      .order('created_at DESC')
      .sort_by { |r| r.user.anonymous? ? 1 : 0 }
    @message = message
  end

  def create_params
    @create_params ||= params.permit(:author, :text, :page, :rate, :category)
  end

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
