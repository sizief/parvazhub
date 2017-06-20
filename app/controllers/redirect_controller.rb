class RedirectController < ApplicationController
  def redirect
    flight_price_id = params[:flight_price_id]
    redirect = Redirect.new
    redirect.flight_price_id = flight_price_id
    redirect.save
    @flight_price = FlightPrice.find(flight_price_id)
    redirect_to @flight_price.deep_link
  end
end
