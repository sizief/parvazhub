class SearchController < ApplicationController
  def flight
  end

  def save_result
    origin = params[:search][:origin].downcase
    destination = params[:search][:destination].downcase
    date = params[:search][:date]
    route_id = route_id(origin,destination)

    import_flights(origin,destination,route_id,date)
    import_price()
    render html: route_id
  end

  #give the route id for given destination and origin
  def route_id(origin,destination)
     route = Route.select(:id).find_by(origin:"#{origin}",destination:"#{destination}")
     if route.nil? #create this route if it is not exist is database
      route = StaticDataController.import_route("#{origin}","#{destination}")
     end
     route.id
  end

    #give the route id for given destination and origin
  def flight_id(flight_number)
    flight = Flight.select(:id).find_by(flight_number:"#{flight_number}")
    flight.id
  end

  def import_flights(origin,destination, route_id,date)
    response = zoraq_search(origin, destination,date) 
    json_response = JSON.parse(response)
    json_response["PricedItineraries"].each do |flight|
      flight_number = airline_code = airplane_type = departure_date_time = is_flight_created  = nil
      flight_legs = flight["OriginDestinationOptions"][0]["FlightSegments"]
      flight_legs.each do |leg|
        #to add airline code to flight number for some corrupted flight numbers
        if leg["FlightNumber"].count(leg["OperatingAirline"]["Code"]) == 0
          correct_flight_number = leg["OperatingAirline"]["Code"]+leg["FlightNumber"]
        else
          correct_flight_number = leg["FlightNumber"]
        end

        flight_number = flight_number.nil? ? correct_flight_number : flight_number +"|"+correct_flight_number
        airline_code = airline_code.nil? ? leg["OperatingAirline"]["Code"] : airline_code +"|"+leg["OperatingAirline"]["Code"]
        airplane_type = airplane_type.nil? ? leg["OperatingAirline"]["Equipment"] : airplane_type +"|"+leg["OperatingAirline"]["Equipment"]
        departure_date_time = departure_date_time.nil? ? leg["DepartureDateTime"] : departure_date_time # +"|"+leg["DepartureDateTime"]
      end

      departure_date_time = parse_date(departure_date_time)
      departure_time = departure_date_time.strftime("%H:%M")
      Flight.create(route_id: "#{route_id}", flight_number:"#{flight_number}", departure_time:"#{departure_time}", airline_code:"#{airline_code}", airplane_type: "#{airplane_type}")

      departure_date = departure_date_time.strftime("%F")
      price = flight["AirItineraryPricingInfo"]["PTC_FareBreakdowns"][0]["PassengerFare"]["TotalFare"]["Amount"]
      flight_id = flight_id(flight_number)
      FlightPrice.create(flight_id: "#{flight_id}", price: "#{price}", supplier:"zoraq", flight_date:"#{departure_date}" )
    
    end
  end

  def import_price(flight_id,supplier,flight_date,price)
      #create new flightPrice object
  end

  def zoraq_search(origin,destination,date)
  	require "uri"
  	require "net/http"
    begin
  	   params = {'OrginLocationIata' => "#{origin.upcase}", 'DestLocationIata' => "#{destination.upcase}", 'DepartureGo' => "#{date}", 'Passengers[0].Type' =>'ADT', 'Passengers[0].Quantity'=>'1'}
  	   x = Net::HTTP.post_form(URI.parse('http://zoraq.com/Flight/DeepLinkSearch'), params)
  	   x.body
    rescue
      puts "Request time out"   
    end
	end

  def parse_date(datestring)
    seconds_since_epoch = datestring.scan(/[0-9]+/)[0].to_i / 1000.0
    return Time.at(seconds_since_epoch)
  end

end