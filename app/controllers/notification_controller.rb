class NotificationController < ApplicationController
 
  def price_alert_register
  	email = params[:email]
  	origin = params[:origin]
  	destination = params[:destination]
  	date = params[:date]

  	route = Route.find_by(origin:origin,destination:destination)
  	if Notification.price_alert_register(route.id,date,email)
	  @message = "هر روز هشت صبح قیمت‌های مسیر #{city[origin.to_sym][:fa]} به #{city[destination.to_sym][:fa]} به آدرس #{email} ارسال می‌شود. متشکریم! "
	else
	  @message="ببخشید خطایی رخ داد. لطفا دوباره آدرس را وارد کنید."
	end

  	respond_to do |format|
        format.js 
        format.html
    end
  end

end
