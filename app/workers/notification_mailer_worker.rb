require 'sidekiq-scheduler'

class NotificationMailerWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true
  @@city = City.list

  def perform
  	list = Notification.where(notification_type:"price_alert").where(status:true)
    list.each do |subscriber|
      if subscriber.date.to_date >=  Date.today
      	send_email(subscriber) 
      else 
      	subscriber.status = false
      	subscriber.save()
      end
    end
  end

  def send_email(subscriber)
    route = Route.find(subscriber.route_id)
    subject = "پروازهای "+@@city[route[:origin].to_sym][:fa] + " به " +@@city[route[:destination].to_sym][:fa]
    NotificationMailer.price_alert(subscriber.route_id,subscriber.date,subscriber.email,subject).deliver_now
  end

end