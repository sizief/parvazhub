class RedirectController < ApplicationController  
require 'uri'

  def define_args
    {
     origin_name: params[:origin_name],
     destination_name: params[:destination_name],
     date: params[:date],
     flight_id: params[:flight_id],
     flight_price_id: params[:flight_price_id],
     channel: params[:channel]
    }
  end

  def save_redirect args,flight_price,deep_link,request
    redirect = Redirect.new(channel: args[:channel],
                            user_agent: request.user_agent,
                            remote_ip: request.remote_ip,
                            flight_id: flight_price.flight_id,
                            price: flight_price.price,
                            supplier: flight_price.supplier,
                            deep_link: deep_link)                                                      

    unless is_bot(request.user_agent)
      redirect.save 
      #text="👊 [#{Rails.env}] #{request.user_agent} #{request.remote_ip} \n #{@flight_price.supplier}"
      #TelegramMonitoringWorker.perform_async(text)
    end
  end

  def create_deep_link flight_price
    if flight_price.is_deep_link_url
      deep_link = flight_price.deep_link
    else
      supplier_class = "Suppliers::"+flight_price.supplier.capitalize
      deep_link = supplier_class.constantize.create_deep_link flight_price.deep_link
    end
    deep_link += deep_link.include?("?") ? "&" : "?"
    deep_link += "utm_source=parvazhub_com&utm_medium=meta_search&utm_campaign=parvazhub_com"  
  end

  def redirect
    args = define_args
    
    begin
      @flight_price = FlightPrice.find(args[:flight_price_id])
    rescue
      @flight_price = nil
    end
    
    @flight_price_link = flight_prices_path(args[:origin_name], 
                                            args[:destination_name], 
                                            args[:date], 
                                            args[:flight_id])

    if @flight_price
      @action_link = create_deep_link @flight_price
      @supplier = @flight_price.supplier
      @method = "GET"  
      save_redirect args,@flight_price,@action_link,request
    end
  end

end
