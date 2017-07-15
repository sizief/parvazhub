class RedirectController < ApplicationController
  def redirect
    flight_price_id = params[:flight_price_id]
    redirect = Redirect.new
    flight_price = FlightPrice.find(flight_price_id)
    flight_price_archive = FlightPriceArchive.find_by(flight_id: flight_price.flight_id,
                                                      flight_date: flight_price.flight_date,
                                                      supplier: flight_price.supplier)
    redirect.flight_price_archive_id = flight_price_archive.id
    redirect.save
    @flight_price = FlightPrice.find(flight_price_id)
    redirect_to @flight_price.deep_link
  end
end
