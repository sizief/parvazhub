# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  before_action :authenticate_admin

  def index; end
  def weekly_stats; end
  def users; end

  def redirects
    today_redirects = calculate_redirects(Date.today, Date.today + 1)
    all_redirects = calculate_redirects(Date.today - 365, Date.today + 1)
    this_week_redirects = calculate_redirects(Date.today - 7, Date.today + 1)
    this_month_redirects = calculate_redirects(
      (
        Date.today -
          JalaliDate.new(
            Date.today.to_date
          )
        .strftime('%d')
        .to_i
      ), Date.today + 1
    )
    @results = { this_month: this_month_redirects, today: today_redirects, all: all_redirects, this_week: this_week_redirects}
  end

  def search_histories
    @sh = SearchHistory.includes(:route).order(id: :desc).first(100)
  end

  def suppliers
    @supplier_list = Supplier.all
  end

  def update_supplier
    id = params[:id]
    status = params[:status]
    supplier = Supplier.find(id)
    supplier[:status] = status
    supplier.save
    @supplier_list = Supplier.all
    render :suppliers
  end

  def reviews
    @reviews = Review.all
  end

  def show_user
    @user = User.find(params[:id])
  end

  def update_review
    Review.find(review_params[:id]).update(review_params)
    redirect_to action: 'reviews'
  end

  def delete_review
    Review.find(review_params[:id]).destroy
    redirect_to action: 'reviews'
  end

  private

  def review_params
    params.require(:review).permit(:id, :published)
  end

  private

  def calculate_redirects(begin_date, end_date)
    supplier = {}
    Redirect.where('created_at > ? and created_at <?', begin_date, end_date).each do |redirect|
      if supplier[redirect.supplier.to_sym].nil?
        supplier[redirect.supplier.to_sym] = 0
      end
      supplier[redirect.supplier.to_sym] += 1
    end
    supplier = Hash[supplier.sort_by { |key, _val| key }]
  end
end
