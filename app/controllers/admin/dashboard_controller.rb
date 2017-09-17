class Admin::DashboardController < ApplicationController
  def user_search_history
  	@ush = UserSearchHistory.order(id: :desc).first(500)
  end

  def search_history
  	@sh = SearchHistory.order(id: :desc).first(300)
  end

  def supplier_control
  	@supplier_list = Supplier.all
  end

  def update_supplier
  	id = params[:id]
  	status = params[:status]
  	supplier = Supplier.find(id)
  	supplier[:status] = status
  	supplier.save
  	@supplier_list = Supplier.all
  	render :supplier_control
  end

  def price_alert
    @subscribers = Notification.all
  end

  def index
  end
      
  def redirect
    all = Hash.new
    today = Hash.new
    this_week = Hash.new
    week_before = Hash.new
    week_before_that = Hash.new
    
    Redirect.all.each do |redirect|
      flight_price_archive = FlightPriceArchive.find(redirect.flight_price_archive_id)
      all[flight_price_archive.supplier.to_sym] = 0 if all[flight_price_archive.supplier.to_sym].nil?
      all[flight_price_archive.supplier.to_sym] = all[flight_price_archive.supplier.to_sym] + 1
    end
    all = Hash[ all.sort_by { |key, val| key } ]  
    
    Redirect.where('created_at > ?',Date.today).each do |redirect|
      flight_price_archive = FlightPriceArchive.find(redirect.flight_price_archive_id)
      today[flight_price_archive.supplier.to_sym] = 0 if today[flight_price_archive.supplier.to_sym].nil?
      today[flight_price_archive.supplier.to_sym] = today[flight_price_archive.supplier.to_sym] + 1
    end
    today = Hash[ today.sort_by { |key, val| key } ]  
   
    Redirect.where('created_at > ?',Date.today-7).each do |redirect|
      flight_price_archive = FlightPriceArchive.find(redirect.flight_price_archive_id)
      this_week[flight_price_archive.supplier.to_sym] = 0 if this_week[flight_price_archive.supplier.to_sym].nil?
      this_week[flight_price_archive.supplier.to_sym] = this_week[flight_price_archive.supplier.to_sym] + 1
    end
    this_week = Hash[ this_week.sort_by { |key, val| key } ]
    
    Redirect.where('created_at > ? and created_at <?',Date.today-14,Date.today-7).each do |redirect|
      flight_price_archive = FlightPriceArchive.find(redirect.flight_price_archive_id)
      week_before[flight_price_archive.supplier.to_sym] = 0 if week_before[flight_price_archive.supplier.to_sym].nil?
      week_before[flight_price_archive.supplier.to_sym] = week_before[flight_price_archive.supplier.to_sym] + 1
    end
    week_before = Hash[ week_before.sort_by { |key, val| key } ]

    Redirect.where('created_at > ? and created_at <?',Date.today-21,Date.today-14).each do |redirect|
      flight_price_archive = FlightPriceArchive.find(redirect.flight_price_archive_id)
      week_before_that[flight_price_archive.supplier.to_sym] = 0 if week_before_that[flight_price_archive.supplier.to_sym].nil?
      week_before_that[flight_price_archive.supplier.to_sym] = week_before_that[flight_price_archive.supplier.to_sym] + 1
    end
    week_before_that = Hash[ week_before_that.sort_by { |key, val| key } ]
    
    @results = {today:today,all:all,this_week:this_week,week_before:week_before,week_before_that:week_before_that}
    
  end

  def user_search_stat
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
      hash_key = (user_search_history.departure_time.to_date - user_search_history.created_at.to_date).to_i
      if @dates_count[hash_key] 
        @dates_count[hash_key] +=1
      else
        @dates_count[hash_key] = 1
      end
    end
    @dates_count = Hash[@dates_count.sort_by{|k, v| v}.reverse]
  end
  
end
