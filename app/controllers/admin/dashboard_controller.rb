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
    this_week = Hash.new
    week_before = Hash.new
    week_before_that = Hash.new
    

    
    Redirect.all.each do |redirect|
      flight_price_archive = FlightPriceArchive.find(redirect.flight_price_archive_id)
      all[flight_price_archive.supplier.to_sym] = 0 if all[flight_price_archive.supplier.to_sym].nil?
      all[flight_price_archive.supplier.to_sym] = all[flight_price_archive.supplier.to_sym] + 1
    end
    all = Hash[ all.sort_by { |key, val| key } ]  
   
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
    
    @results = {all:all,this_week:this_week,week_before:week_before,week_before_that:week_before_that}
    
  end
  
end
