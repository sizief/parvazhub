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

    origin = City.find_by(english_name: origin_name.downcase) 
    destination = City.find_by(english_name: destination_name.downcase)
    origin_city_code = origin.nil? ? false : origin.city_code
    destination_city_code = destination.nil? ? false : destination.city_code
    
    route = Route.new.get_route(origin_city_code,destination_city_code)

    if route.nil?
      notfound
    else
      search_suppliers(route,date,"website",request.user_agent)
      index(route,origin,destination,date)
    end 
  end

  def search_suppliers(route,date,channel,request_user_agent)
    unless is_bot(request_user_agent)
      text = "☝️ [#{Rails.env}] #{route.id}, #{date} \n #{request_user_agent}"
      UserSearchHistoryWorker.perform_async(text,route.id,date,channel)
    end
    response_available = SearchHistory.where(route_id:route.id,departure_time:"#{date}").where('created_at >= ?', allow_response_time(date).to_f.minutes.ago).count
    if ((response_available == 0) and (date >= Date.today.to_s))
      SupplierSearch.new.search(route.origin,route.destination,date,20,"user") 
    end
  end

  def allow_response_time(date)
    if date == Date.today.to_s #today
      allow_time = 10
    elsif date == (Date.today+1).to_s #tomorrow
      allow_time = 20
    elsif date == (Date.today+2).to_s #day after
      allow_time = 60
    elsif date == (Date.today+3).to_s #rest 1
      allow_time = 120
    elsif date == (Date.today+4).to_s #rest 2
      allow_time = 120
    elsif date == (Date.today+5).to_s #rest 3
      allow_time = 120
    elsif date == (Date.today+6).to_s #rest 4
      allow_time = 120
    else
      allow_time = 1440
    end
    return allow_time
  end

  def notfound
    render :notfound
  end

  def index(route,origin,destination,date)
     @flights = date >= Date.today.to_s ? Flight.new.flight_list(route,date) : @flights = Array.new
     date_in_human = date.to_date.to_parsi.strftime '%A %-d %B'     
     @search_parameter ={origin_english_name: origin.english_name, origin_persian_name: origin.persian_name, origin_code: origin.city_code,
                         destination_english_name: destination.english_name, destination_persian_name: destination.persian_name, destination_code: destination.city_code,
                         date: date, date_in_human: date_in_human}
     @airline_english_list = Airline.english_hash_list
     @route_days = RouteDay.week_days(origin.city_code,destination.city_code)
     
     if date <= Date.today.to_s
       @flight_dates = Flight.new.get_lowest_price_time_table(origin.city_code,destination.city_code,Date.today.to_s)
     else
       @flight_dates = Flight.new.get_lowest_price_time_table(origin.city_code,destination.city_code,date)
     end   
     @is_mobile = browser.device.mobile?    

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

    date_in_human = date.to_date.to_parsi.strftime '%A %d %B'   
    @flight = Flight.find(flight_id)
    @search_parameter ={origin_english_name: origin.english_name, origin_persian_name: origin.persian_name, origin_code: origin.city_code,
    destination_english_name: destination.english_name, destination_persian_name: destination.persian_name, destination_code: destination.city_code,
    date: date, date_in_human: date_in_human}
    @flight_prices = get_flight_price("website",params[:id],request.user_agent)
    @flight_price_over_time = FlightPriceArchive.flight_price_over_time(flight_id,date)
    @flight_price_over_time.each do |date,price|
      @dates <<  date.to_s.to_date.to_parsi.strftime("%A %d %B")
      @prices << price
    end
   
    render :flight_price
  end

  def get_flight_price(channel,flight_id,request_user_agent)
    unless is_bot(request_user_agent)
      text = "✌️ [#{Rails.env}] #{flight_id} \n #{request_user_agent}"
      UserFlightPriceHistoryWorker.perform_async(channel,text,flight_id)
    end
    results = FlightPrice.where(flight_id: flight_id).order(:price)
    return results
  end

  
end