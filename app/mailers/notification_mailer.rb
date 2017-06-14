class NotificationMailer < ApplicationMailer
  default from: "Parvazhub Notification<salam@parvazhub.com>"
  add_template_helper(SearchHelper) 

  def price_alert(route_id,date,email,subject)
  	route = Route.find(route_id)
  	@flights = Flight.new.flight_list(route,date)
  	@email =email
    @search_parameter ={origin: route[:origin],destination: route[:destination],date: date}
    @cities = City.list 

    mail(to: @email, subject: subject, bcc:"sizief@gmail.com")
  end
end
