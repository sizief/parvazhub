class Flight < ApplicationRecord
	validates :flight_number, uniqueness: true

	def import_zoraq_flights(zoraq_response,route_id)
      json_response = JSON.parse(zoraq_response)
      json_response["PricedItineraries"].each do |flight|
        flight_number = airline_code = airplane_type = departure_date_time = is_flight_created  = nil
        flight_legs = flight["OriginDestinationOptions"][0]["FlightSegments"]
      
        flight_legs.each do |leg|
          #to add airline code to flight number for some corrupted flight numbers
          #for example there is 4545 flight number which is not correct
          #the correct format is w54545
          if leg["FlightNumber"].count(leg["OperatingAirline"]["Code"]) == 0
            correct_flight_number = leg["OperatingAirline"]["Code"]+leg["FlightNumber"]
          else
            correct_flight_number = leg["FlightNumber"]
          end

          flight_number = flight_number.nil? ? correct_flight_number : flight_number +"|"+correct_flight_number
          airline_code = airline_code.nil? ? leg["OperatingAirline"]["Code"] : airline_code +"|"+leg["OperatingAirline"]["Code"]
          airplane_type = airplane_type.nil? ? leg["OperatingAirline"]["Equipment"] : airplane_type +"|"+leg["OperatingAirline"]["Equipment"]
          #we need just first departre date time, so the other leg's departre time is commented
          departure_date_time = departure_date_time.nil? ? leg["DepartureDateTime"] : departure_date_time # +"|"+leg["DepartureDateTime"]
        end

        departure_date_time = parse_date(departure_date_time)
        departure_time = departure_date_time.strftime("%H:%M")
        Flight.create(route_id: "#{route_id}", flight_number:"#{flight_number}", departure_time:"#{departure_time}", airline_code:"#{airline_code}", airplane_type: "#{airplane_type}")

        departure_date = departure_date_time.strftime("%F")
        price = flight["AirItineraryPricingInfo"]["PTC_FareBreakdowns"][0]["PassengerFare"]["TotalFare"]["Amount"]
        flight_id = flight_id(flight_number)
        FlightPrice.create(flight_id: "#{flight_id}", price: "#{price}", supplier:"zoraq", flight_date:"#{departure_date}" )
      end #end of each loop
  end

  def parse_date(datestring)
    seconds_since_epoch = datestring.scan(/[0-9]+/)[0].to_i / 1000.0
    return Time.at(seconds_since_epoch)
  end

   def flight_id(flight_number)
    flight = Flight.select(:id).find_by(flight_number:"#{flight_number}")
    flight.id
  end
end
