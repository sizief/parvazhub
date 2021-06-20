# frozen_string_literal: true

class RedirectController < ApplicationController
  def define_args
    {
      origin_name: params[:origin_name],
      destination_name: params[:destination_name],
      date: params[:date],
      flight_id: params[:flight_id],
      flight_price_id: params[:flight_price_id],
      channel: params[:channel],
      user_id: params[:user_id]
    }
  end

  def save_redirect(args, flight_price, deep_link, request)
    user = args[:user_id].nil? ? current_user : User.find_by(id: args[:user_id])
    redirect = Redirect.new(channel: args[:channel],
                            user_agent: request.user_agent,
                            remote_ip: request.remote_ip,
                            flight_id: flight_price.flight_id,
                            price: flight_price.price,
                            supplier: flight_price.supplier,
                            deep_link: deep_link,
                            user: user)

    unless is_bot(request.user_agent)
      redirect.save
    end
  end

  def redirect
    args = define_args

    begin
      @flight_price = FlightPrice.find(args[:flight_price_id])
    rescue StandardError
      @flight_price = nil
    end

    @flight_price_link = flight_prices_path(args[:origin_name],
                                            args[:destination_name],
                                            args[:date],
                                            args[:flight_id])

    if @flight_price
      @action_link = @flight_price.deep_link
      @supplier = @flight_price.supplier
      @method = 'GET'
      save_redirect args, @flight_price, @action_link, request
    end
  end
end
