class SearchResultController < ApplicationController
  
  def flight_search
    origin = params[:search][:origin].downcase
    destination = params[:search][:destination].downcase
    date = params[:search][:date]

    redirect_to  action: 'search', origin_name: origin, destination_name: destination, date: date
  end

  def search 
    origin_name = params[:origin_name].downcase
    destination_name = params[:destination_name].downcase
    if params[:date] == "today"
        date = Date.today.to_s
    elsif params[:date] == "tomorrow"
        date = (Date.today+1).to_s
    else
        date = params[:date]
    end

    if date < Date.today.to_s 
        redirect_to  action: 'search', origin_name: origin_name, destination_name: destination_name, date: "today"
        return
    end

    route = Route.new.get_route_by_english_name(origin_name,destination_name)
    if route.nil? 
        notfound
    else 
        flights = get_flight_results(route,date,"website",request.user_agent)
        index(route,date,flights)
    end
  end

  def get_flight_results(route,date,channel,user_agent_request)
    if is_bot(user_agent_request)
        # do not search supplier, just get results from db
        flights = get_flights(date,route,true)
    else
        text = "☝️ [#{Rails.env} | #{channel}] #{route.id}, #{date} \n #{user_agent_request}"
        UserSearchHistoryWorker.perform_async(text,route.id,date,channel) unless Rails.env.test?
        flights = get_flights(date,route,false)
    end
    return flights
  end

  def notfound
    render :notfound
  end

  def index(route,date,flights)
    @flights = flights
    origin = City.find_by(city_code: route.origin)
    destination = City.find_by(city_code: route.destination)
    date_in_human = date_to_human date    
    @search_parameter ={origin_english_name: origin.english_name, origin_persian_name: origin.persian_name, origin_code: origin.city_code,
                            destination_english_name: destination.english_name, destination_persian_name: destination.persian_name, destination_code: destination.city_code,
                            date: date, date_in_human: date_in_human, international: route.international}
    @route_days = RouteDay.week_days(origin.city_code,destination.city_code)
        
    if date <= Date.today.to_s
      @flight_dates = Flight.new.get_lowest_price_timetable(origin.city_code,destination.city_code,Date.today.to_s)
    else
      @flight_dates = Flight.new.get_lowest_price_timetable(origin.city_code,destination.city_code,date)
    end   
    @is_mobile = browser.device.mobile?    
    @prices = Flight.new.get_lowest_price_for_a_month(origin.city_code, destination.city_code, Date.today)

    render :index
  end

  def flight_prices
    origin_name = params[:origin_name].downcase
    destination_name = params[:destination_name].downcase
    date = params[:date]
    flight_id = params[:id]
    @dates = Array.new
    @prices = Array.new

    origin = City.find_by(english_name: origin_name.downcase) 
    destination = City.find_by(english_name: destination_name.downcase)

    date_in_human = date_to_human date #date.to_date.to_parsi.strftime '%A %d %B'   
    @flight = Flight.find(flight_id)
    @search_parameter ={origin_english_name: origin.english_name, origin_persian_name: origin.persian_name, origin_code: origin.city_code,
                        destination_english_name: destination.english_name, destination_persian_name: destination.persian_name, destination_code: destination.city_code,
                        date: date, date_in_human: date_in_human}
    @flight_prices = get_flight_price(@flight,"website",request.user_agent)
    @flight_price_over_time = FlightPriceArchive.flight_price_over_time(flight_id,date)
    @flight_price_over_time.each do |date,price|
        @dates <<  date.to_s.to_date.to_parsi.strftime("%A %d %B")
        @prices << price
    end
    
    @airline = Airline.find_by(code: @flight.airline_code.split(",").first)
    @reviews = get_reviews @airline
  
    render :flight_price
  end

  def get_flight_price(flight,channel,request_user_agent)
    unless is_bot(request_user_agent)
        text = "✌️ [#{Rails.env} | #{channel}] #{flight.id} \n #{request_user_agent}"
        UserFlightPriceHistoryWorker.perform_async(channel,text,flight.id) unless Rails.env.test?
    end
    FlightResult.new.get_flight_price(flight)
  end

  private

  def get_reviews airline
    if airline.nil?
      reviews = Array.new
    else
      reviews = Review.where(page: airline.english_name).where.not(text:"")
    end
  end

  def get_flights(date,route,is_bot)
    if is_bot
        FlightResult.new(route,date).get_archive
    else
        date >= Date.today.to_s ? FlightResult.new(route,date).get : Array.new
    end
  end

  def date_to_human date
    date = date.to_date
    if date == Date.today
      "امروز"
    elsif date == (Date.today+1) 
      "فردا"
    else
      date.to_date.to_parsi.strftime ' %-d %B' 
    end
  end

      
end