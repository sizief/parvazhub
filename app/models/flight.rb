class Flight < ApplicationRecord
	validates :flight_number, :uniqueness => { :scope => :departure_time,
    :message => "already saved" }
  validates :route_id, presence: true
  belongs_to :route
  has_one :flight_price


	def import_zoraq_flights(zoraq_response,route_id)
      json_response = JSON.parse(zoraq_response)
      json_response["PricedItineraries"].each do |flight|
        flight_number = airline_code = airplane_type = departure_date_time  = nil
        flight_legs = flight["OriginDestinationOptions"][0]["FlightSegments"]
      
        flight_legs.each do |leg|
          correct_airline_code = airline_code_correction(leg["OperatingAirline"]["Code"])

          #to add airline code to flight number for some corrupted flight numbers
          #for example there is 4545 flight number which is not correct
          #the correct format is w54545
          if leg["FlightNumber"].include? correct_airline_code
            correct_flight_number = leg["FlightNumber"]
          else
            correct_flight_number = correct_airline_code+leg["FlightNumber"]
          end

          flight_number = flight_number.nil? ? correct_flight_number : flight_number +"|"+correct_flight_number
          airline_code = airline_code.nil? ? correct_airline_code : airline_code +"|"+correct_airline_code
          airplane_type = airplane_type.nil? ? leg["OperatingAirline"]["Equipment"] : airplane_type +"|"+leg["OperatingAirline"]["Equipment"]
          #we need just first departre date time, so the other leg's departre time is commented
          departure_date_time = departure_date_time.nil? ? leg["DepartureDateTime"] : departure_date_time # +"|"+leg["DepartureDateTime"]
        end

        departure_date_time = parse_date(departure_date_time)
        departure_time = departure_date_time + 210.minutes # add 3:30 hours because zoraq date time is in iran time zone #.strftime("%H:%M")
        
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

  def airline_code_correction(zoraq_airline_code)
  	airline_codes = {
  		"ak":"@1", #Atrak Airlines
  		"b9":"@2", #Iran Airtour
  		"sepahan":"@3", #Sepahan Airlines
  		"hesa":"@4", #Hesa 
  		"i3":"@5", #ATA Airlines
  		"ji":"@7", #Meraj
  		"iv":"@8", #Caspian Airlines
  		"nv":"@9", #Iranian Naft Airlines
  		"saha":"@A", #Saha
  		"zv":"@B" #Zagros 
  	}
  	if airline_codes.key("#{zoraq_airline_code}").nil?
  	  return zoraq_airline_code
  	else
      return airline_codes.key("#{zoraq_airline_code}").to_s
  	end
  end


end
