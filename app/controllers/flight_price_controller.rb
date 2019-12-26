class FlightPriceController < ApplicationController

  def index
    origin_name = params[:origin_name].downcase
    destination_name = params[:destination_name].downcase
    date = params[:date]
    flight_id = params[:id]
    channel = "website"
    @dates, @georgian_dates, @prices = Array.new, Array.new, Array.new

    origin = City.find_by(english_name: origin_name.downcase) 
    destination = City.find_by(english_name: destination_name.downcase)

    date_in_human = date_to_human date 
    @flight = Flight.find(flight_id)
    @user = get_current_user(channel, nil) 
    @search_parameter ={origin_english_name: origin.english_name, origin_persian_name: origin.persian_name, origin_code: origin.city_code,
                        destination_english_name: destination.english_name, destination_persian_name: destination.persian_name, destination_code: destination.city_code,
                        date: date, date_in_human: date_in_human}
    
    @flight_prices = get_flight_price(@flight,channel,request.user_agent, current_user)
    @flight_price_over_time = FlightPriceArchive.flight_price_over_time(flight_id,date)
    @flight_price_over_time.each do |date,price|
      @georgian_dates <<  date.to_s.to_date.strftime("%A %d %B")
      @dates <<  JalaliDate.new(date.to_s.to_date).strftime("%A %d %b")
        @prices << price
    end
    
    @airline = Airline.find_by(code: @flight.airline_code.split(",").first) 
    @reviews = get_reviews @airline
  
    render :index
  end

  def get_flight_price(flight,channel,user_agent_request,user)
    flight_price_background_archive(channel,flight,user)  unless is_bot(user_agent_request)
    FlightResult.new.get_flight_price(flight)
  end

  private

  def flight_price_background_archive channel,flight,user
    if Rails.env.production?
      UserFlightPriceHistoryWorker.perform_async(channel,flight.id,user.id) 
      AmplitudeWorker.perform_async(user.id,"supplierPage",channel)
    else
      UserFlightPriceHistory.create(flight_id: flight.id,channel: channel, user: user)
    end
  end

  def get_reviews airline
    if airline.nil?
      reviews = Array.new
    else
      reviews = Review.where(page: airline.english_name).where.not(text:"")
    end
  end

  def date_to_human date
    date = date.to_date
    if date == Date.today
      "امروز"
    elsif date == (Date.today+1) 
      "فردا"
    else
      JalaliDate.new(date.to_date).strftime ' %d %b' 
    end
  end

  def get_current_user(channel, user_agent_request) 
    user = automatic_login({channel: channel, user_agent_request: user_agent_request})
  end   
end
