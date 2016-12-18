class SearchController < ApplicationController
  def flight
  end

  def results
  	
  	origin = params[:search][:origin].downcase
  	destination = params[:search][:destination].downcase
    route_id = route_id(origin,destination)
    response = zoraq_search(origin, destination) 
    #debugger
    json_response = JSON.parse(response)
    json_response["PricedItineraries"].each do |flight|
      flight_number = flight["OriginDestinationOptions"][0]["FlightSegments"][0]["FlightNumber"]
      airline_name = flight["OriginDestinationOptions"][0]["FlightSegments"][0]["OperatingAirline"]["Code"]
      departure_time = flight["OriginDestinationOptions"][0]["FlightSegments"][0]["DepartureDateTime"]
      departure_time = parse_date(departure_time)
      
      #puts "#{route_id}, #{flight_number}, #{airline}, #{departure_time}"
      Flight.create(route_id: "#{route_id}", flight_number:"#{flight_number}", deaprture_time:"#{departure_time}", airline_name:"#{airline_name}")
    end
    #render html: response

  end

  def zoraq_search(origin,destination)
  	require "uri"
  	require "net/http"

  	params = {'OrginLocationIata' => "#{origin.upcase}", 'DestLocationIata' => "#{destination.upcase}", 'DepartureGo' => '12/20/2016 00:00:00 AM', 'DepartureReturn' => '12/21/2016 00:00:00 AM', 'Passengers[0].Type' =>'ADT', 'Passengers[0].Quantity'=>'1'}
  	#params = {'OrginLocationIata' => "IKA", 'DestLocationIata' => "DXB", 'DepartureGo' => '12/20/2016 00:00:00 AM', 'DepartureReturn' => '12/21/2016 00:00:00 AM', 'Passengers[0].Type' =>'ADT', 'Passengers[0].Quantity'=>'1'}

  	x = Net::HTTP.post_form(URI.parse('http://zoraq.com/Flight/DeepLinkSearch'), params)
  	x.body
	end

  def route_id(origin,destination)
     route = Route.select(:id).find_by(origin:"#{origin}",destination:"#{destination}")
     route.id if !route.nil?
  end

  def parse_date(datestring)
    seconds_since_epoch = datestring.scan(/[0-9]+/)[0].to_i / 1000.0
    return Time.at(seconds_since_epoch)
  end


end
