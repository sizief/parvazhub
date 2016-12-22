class SearchController < ApplicationController
  def flight
  end

  def save_result
    origin = params[:search][:origin].downcase
    destination = params[:search][:destination].downcase
    route_id = route_id(origin,destination)

    import_flights(origin,destination,route_id)
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

  def import_flights(origin,destination, route_id)
    response = zoraq_search(origin, destination) 
    json_response = JSON.parse(response)
    json_response["PricedItineraries"].each do |flight|
      flight_number = flight["OriginDestinationOptions"][0]["FlightSegments"][0]["FlightNumber"]
      airline_code = flight["OriginDestinationOptions"][0]["FlightSegments"][0]["OperatingAirline"]["Code"]
      airplane_type = flight["OriginDestinationOptions"][0]["FlightSegments"][0]["OperatingAirline"]["Equipment"]
      departure_date_time = flight["OriginDestinationOptions"][0]["FlightSegments"][0]["DepartureDateTime"]
      departure_date_time = parse_date(departure_date_time)
      departure_time = departure_date_time.strftime("%H:%M")
      flight_created = Flight.create(route_id: "#{route_id}", flight_number:"#{flight_number}", departure_time:"#{departure_time}", airline_code:"#{airline_code}", airplane_type: "#{airplane_type}")
      if flight_created.valid?
        #import_price()
    end
  end

  def import_price(flight_id,supplier,flight_date,price)
      #create new flightPrice object
  end

  def zoraq_search(origin,destination)
  	require "uri"
  	require "net/http"
    begin
  	   params = {'OrginLocationIata' => "#{origin.upcase}", 'DestLocationIata' => "#{destination.upcase}", 'DepartureGo' => '12/25/2016 00:00:00 AM', 'DepartureReturn' => '12/26/2016 00:00:00 AM', 'Passengers[0].Type' =>'ADT', 'Passengers[0].Quantity'=>'1'}
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
