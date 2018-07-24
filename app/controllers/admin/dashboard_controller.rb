class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def user_search_histories
  	@ush = UserSearchHistory.includes(:route).order(id: :desc).first(500)
  end

  def search_histories
  	@sh = SearchHistory.includes(:route).order(id: :desc).first(300)
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

  def index
    @channels = ["website","telegram","android","ionic"]
  end

  def weekly_stats
    @channels = ["website","telegram","android","ionic"]
    @show_search_history = false
  end

  def users
    @channel = params[:channel]
    if @channel.nil?
      @users = User.left_joins(:user_search_histories).group(:id).order('COUNT(user_search_histories.id) DESC').limit(1000)
    else
      @users = User.where(channel: @channel).left_joins(:user_search_histories).group(:id).order('COUNT(user_search_histories.id) DESC').limit(1000)
    end
  end
      
  def redirects
    today_redirects =  calculate_redirects(Date.today, Date.today+1)
    all_redirects =  calculate_redirects(Date.today-365, Date.today+1)
    this_week_redirects =  calculate_redirects(Date.today-7, Date.today+1)
    week_before_redirects =  calculate_redirects(Date.today-14, Date.today-7)
    week_before_that_redirects =  calculate_redirects(Date.today-21, Date.today-14)
    this_month_redirects = calculate_redirects((Date.today-(Date.today.to_date.to_parsi.strftime("%-d")).to_i), Date.today+1)
    @results = {this_month: this_month_redirects, today:today_redirects,all:all_redirects,this_week:this_week_redirects,week_before:week_before_redirects,week_before_that:week_before_that_redirects} 
  end

  def calculate_redirects(begin_date,end_date)
    supplier = Hash.new
    Redirect.where('created_at > ? and created_at <?',begin_date,end_date).each do |redirect|
      supplier[redirect.supplier.to_sym] = 0 if supplier[redirect.supplier.to_sym].nil?
      supplier[redirect.supplier.to_sym] += 1
    end
    supplier = Hash[ supplier.sort_by { |key, val| key } ]  
  end

  def user_search_stats
    user_search_histories = UserSearchHistory.where("created_at >?","2017-09-11")

    @user_search_histories_all = user_search_histories.count
    
    routes_count = user_search_histories.group(:route_id).order('count_id desc').count('id')
    @routes_count_hash = Hash.new
    routes_count.each do |route|
      route_id = route[0]
      route_codes = Route.find(route_id)
      hash_key = route_codes.origin+"-"+route_codes.destination
      @routes_count_hash[hash_key.to_sym] = route[1]
    end

    @dates_count = Hash.new
    user_search_histories.each do |user_search_history|
      
      begin 
        hash_key = (user_search_history.departure_time.to_date - user_search_history.created_at.to_date).to_i
      rescue
        next
      end

      if @dates_count[hash_key] 
        @dates_count[hash_key] +=1
      else
        @dates_count[hash_key] = 1
      end
    end
    @dates_count = Hash[@dates_count.sort_by{|k, v| v}.reverse]
  end

  def update_review
    review = Review.find(review_params[:id])
    review.update(review_params)
    #review.save
  end

  def delete_review
    review = Review.find(review_params[:id])
    review.destroy
  end

  private

  def review_params
    params.require(:review).permit(:id, :published)
  end
  
end
