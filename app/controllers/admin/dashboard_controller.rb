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
      
  
end
