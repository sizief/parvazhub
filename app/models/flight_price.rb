class FlightPrice < ApplicationRecord
	#validates :flight_id, :uniqueness => { :scope =>[:supplier,:flight_date]}
	belongs_to :flight
	#default_scope -> { order(price: :ASC) }

	def self.delete_old_flight_prices(supplier,route_id,date)
    	flights = Flight.where(route_id: route_id).where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s)
    	flights.each do |flight|
      		flight.flight_prices.where(supplier: "#{supplier}").where(flight_date:"#{date}").delete_all
    	end
  	end

  	def get_lowest_price_collection(origin,destination)
    	route = Route.find_by(origin:origin, destination:destination)
    	dates = {today: Date.today.to_s, tomorrow: (Date.today+1).to_s, dayaftertomorrow: (Date.today+2).to_s}
    	prices = {today: '', tomorrow: '', dayaftertomorrow: ''}

    	dates.each do |title,date|
    		prices[title.to_sym] = get_lowest_price(route,date)
    	end
    	
    	prices
    end

    def get_lowest_price_time_table(origin,destination,date)
        route = Route.find_by(origin:origin, destination:destination)
        dates = {twodaybefore: (date.to_date-2).to_s, onedaybefore: (date.to_date-1).to_s, theday: (date.to_date).to_s, dayafter: (date.to_date+1).to_s, twodayafter: (date.to_date+2).to_s}
        prices = {twodaybefore:'', onedaybefore:'',theday:'', dayafter: '', twodayafter: ''}

        dates.each do |title,date|
            prices[title.to_sym] = get_lowest_price(route,date)
        end
        prices
    end

    def get_lowest_price(route,date)
        flight = route.flights.where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s).where.not(best_price:0).sort_by(&:best_price).first
        flight
    end

end
