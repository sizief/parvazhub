class RedirectController < ApplicationController
  

require 'uri'
  def redirect
    
    origin_name = params[:origin_name]
    destination_name = params[:destination_name]
    date = params[:date]
    flight_id = params[:flight_id]
    flight_price_id = params[:flight_price_id]
    channel = params[:channel]
    @flight_price_link = flight_prices_path(origin_name, destination_name, date, flight_id)
    begin
      @flight_price = FlightPrice.find(flight_price_id)
    rescue
      @flight_price = nil
    end

    if @flight_price
      flight_price_archive = FlightPriceArchive.find_by(flight_id: @flight_price.flight_id,
                                                        flight_date: @flight_price.flight_date,
                                                       supplier: @flight_price.supplier)
      redirect = Redirect.new                                                       
      redirect.flight_price_archive_id = flight_price_archive.id
      redirect.channel = channel
      redirect.user_agent = request.user_agent
      redirect.remote_ip = request.remote_ip
      redirect.save

      text="👊 [#{Rails.env}] #{request.user_agent} #{request.remote_ip} \n #{@flight_price.supplier}"
      TelegramMonitoringWorker.perform_async(text)
      
      @supplier = @flight_price.supplier
      @action_link = @flight_price.deep_link
      
      #if @supplier.downcase == "trip"
      #  @method = "POST"
      #  @parameters = {"utm_source":"parvazhub_com","utm_medium":"meta_search","utm_campaign":"parvazhub_com"}
      #else
        @method = "GET"
        @action_link += @action_link.include?("?") ? "&" : "?"
        @action_link += "utm_source=parvazhub_com&utm_medium=meta_search&utm_campaign=parvazhub_com"
        #@action_link = URI.encode(@action_link)
      #end  
    end
  end

end
