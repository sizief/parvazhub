# frozen_string_literal: true

class RedirectController < ApplicationController
  def redirect
    @flight_price = FlightPrice.find_by(id: params[:flight_price_id])

    @flight_price_link = flight_prices_path(
      params[:origin_name],
      params[:destination_name],
      params[:date],
      params[:flight_id]
    )

    if @flight_price
      @redirect_link = @flight_price.deep_link
      @supplier = @flight_price.supplier
      save_redirect(params, @flight_price, @redirect_link, request)
    end
  end

  private

  def save_redirect(args, flight_price, deep_link, request)
    return if is_bot(request.user_agent)

    Redirect.create(
      user_agent: request.user_agent,
      remote_ip: request.remote_ip,
      flight_id: flight_price.flight_id,
      price: flight_price.price,
      supplier: flight_price.supplier,
      deep_link: deep_link,
      user: current_user ? current_user : User.anonymous_user
    )
  end
end
