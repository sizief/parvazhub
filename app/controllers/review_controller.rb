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
  end

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  def register
    author = params[:author]
    rate = params[:rate]
    text = params[:text]
    page = params[:page]
    category = params[:category]
    channel = 'website'

    user = automatic_login(channel: channel, user_agent_request: request.user_agent)
    review = Review.create(author: author, text: text, page: page, rate: rate, user: user, category: category)

    if review.nil?
      @message = 'ببخشید خطایی رخ داد. لطفا دوباره آدرس را وارد کنید.'
    else
      update_user_name author, user.id
      @message = succesful_message author, text
      review_background_jobs page, author, text, rate, user, channel
    end

    respond_to do |format|
      format.js
      format.html
    end
  end

  private

  def review_background_jobs(page, author, text, rate, user, channel)
    if Rails.env.production?
      TelegramMonitoringWorker.perform_async("📣 #{page}, #{author}, #{text}, #{rate}")
      AmplitudeWorker.perform_async(user.id, 'review', channel)
    end
  end

  def update_user_name(author, user_id)
    names = author.split(' ')
    user =  User.find_by(id: user_id)
    user&.update(first_name: names[0], last_name: names[1])
  end

  def succesful_message(author, text)
    first_name = author.empty? ? 'دوست' : author.split(' ')[0]
    message = "#{first_name} عزیز،  <br>"
    message += 'نظرتان ثبت شد و بعد از حداکثر ۱۵ دقیقه در سایت نمایش داده می‌شود. ممنونم که نظرتان را با ما و بقیه کاربران پروازهاب به اشتراک گذاشتید.'
    message += '<br> برای دیدن پیغام‌تان صفحه را رفرش کنید.' unless text.empty?
    message += '<br><br> علی، مدیر پروازهاب'
  end
end
