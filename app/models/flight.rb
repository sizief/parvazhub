class Flight < ApplicationRecord
	validates :flight_number, :uniqueness => { :scope => :departure_time,
    :message => "already saved" }
  validates :route_id, presence: true
  #default_scope -> { order(created_at: :desc) }
  belongs_to :route
  has_many :flight_prices
	
def import_domestic_alibaba_flights(response,route_id,origin,destination,date)
      json_response = JSON.parse(response)
      json_response["AvailableFlights"].each do |flight|
        flight_number = airline_code = airplane_type = departure_date_time  = nil
        corrected_airline_code = alibaba_airline_code_correction(flight["AirLineEnglish"])
        #to add airline code to flight number for some corrupted flight numbers
        if flight["FlightNumber"].upcase.include? corrected_airline_code
            flight_number = flight["FlightNumber"].upcase
        else
            flight_number = corrected_airline_code.upcase+flight["FlightNumber"].delete("^0-9")
        end

        flight_number = flight_number.tr('.','') #sometimes alibaba responses with "." in start or end of a flight number

        airline_code = corrected_airline_code
        airplane_type = flight["Aircraft"]
        
        departure_date_array = flight["LeaveDate"].split("/")
        departure_date = departure_date_array[2]+"-"+departure_date_array[0]+"-"+departure_date_array[1]
        departure_time = flight["LeaveTime"][0..1]+":"+flight["LeaveTime"][2..3]
        departure_date_time = departure_date+" "+departure_time
        departure_time = departure_date_time.to_datetime
        price = flight["price"].to_i/10

        unless price == 0
          Flight.create(route_id: "#{route_id}", flight_number:"#{flight_number}", departure_time:"#{departure_time}", airline_code:"#{airline_code}", airplane_type: "#{airplane_type}")
        end

        unless price == 0
          deeplink_url = "https://alibaba.ir/flights/#{origin}-#{destination}/#{date}/1-0-0" #create alibaba based on one search
          flight_id = flight_id(flight_number,departure_time)
          FlightPrice.create(flight_id: "#{flight_id}", price: "#{price}", supplier:"alibaba", flight_date:"#{departure_date}", deep_link:"#{deeplink_url}"  )
        end
      end #end of each loop
  end


  def import_zoraq_flights(zoraq_response,route_id)
      json_response = JSON.parse(zoraq_response)
      json_response["PricedItineraries"].each do |flight|
        flight_number = airline_code = airplane_type = departure_date_time  = nil
        flight_legs = flight["OriginDestinationOptions"][0]["FlightSegments"]
      
        flight_legs.each do |leg|
          corrected_airline_code = zoraq_airline_code_correction(leg["OperatingAirline"]["Code"])

          #to add airline code to flight number for some corrupted flight numbers
          #for example there is 4545 flight number which is not correct
          #the correct format is w54545
          if leg["FlightNumber"].include? corrected_airline_code
            correct_flight_number = leg["FlightNumber"]
          else
            correct_flight_number = corrected_airline_code+leg["FlightNumber"]
          end

          correct_flight_number = correct_flight_number.tr('.','') #sometimes zoraq responses with "." in start or end of a flight number

          flight_number = flight_number.nil? ? correct_flight_number : flight_number +"|"+correct_flight_number
          airline_code = airline_code.nil? ? corrected_airline_code : airline_code +"|"+corrected_airline_code
          airplane_type = airplane_type.nil? ? leg["OperatingAirline"]["Equipment"] : airplane_type +"|"+leg["OperatingAirline"]["Equipment"]
          #we need just first departre date time, so the other leg's departre time is commented
          departure_date_time = departure_date_time.nil? ? leg["DepartureDateTime"] : departure_date_time # +"|"+leg["DepartureDateTime"]
        end

        departure_time = parse_date(departure_date_time).utc.to_datetime
        departure_time = departure_time + IRAN_ADDITIONAL_TIMEZONE.minutes # add 4:30 hours because zoraq date time is in iran time zone #.strftime("%H:%M")
        
        Flight.create(route_id: "#{route_id}", flight_number:"#{flight_number}", departure_time:"#{departure_time}", airline_code:"#{airline_code}", airplane_type: "#{airplane_type}")

        departure_date = departure_time.strftime("%F")
        price = flight["AirItineraryPricingInfo"]["PTC_FareBreakdowns"][0]["PassengerFare"]["TotalFare"]["Amount"]
        deeplink_url = "http://zoraq.com"+flight["AirItineraryPricingInfo"]["FareSourceCode"]
        flight_id = flight_id(flight_number,departure_time)
        FlightPrice.create(flight_id: "#{flight_id}", price: "#{price}", supplier:"zoraq", flight_date:"#{departure_date}", deep_link:"#{deeplink_url}" )
      end #end of each loop
  end

  def parse_date(datestring)
    seconds_since_epoch = datestring.scan(/[0-9]+/)[0].to_i / 1000.0
    return Time.at(seconds_since_epoch)
  end

  def flight_id(flight_number,departure_time)
    flight = Flight.select(:id).find_by(flight_number:"#{flight_number}", departure_time: "#{departure_time}")
    flight.id
  end

  def zoraq_airline_code_correction(zoraq_airline_code)
  	airline_codes = {
  		"AK":"@1", #Atrak Airlines
  		"B9":"@2", #Iran Airtour
  		"sepahan":"@3", #Sepahan Airlines
  		"hesa":"@4", #Hesa 
  		"I3":"@5", #ATA Airlines
  		"JI":"@7", #Meraj
  		"IV":"@8", #Caspian Airlines
  		"NV":"@9", #Iranian Naft Airlines
  		"saha":"@A", #Saha
  		"ZV":"@B" #Zagros 
  	}
  	if airline_codes.key("#{zoraq_airline_code}").nil?
  	  return zoraq_airline_code.upcase
  	else
      return airline_codes.key("#{zoraq_airline_code}").to_s.upcase
  	end
  end

  def alibaba_airline_code_correction(alibaba_airline_code)
    airline_codes = {
      "IV":"RV"
    }
    if airline_codes.key("#{alibaba_airline_code}").nil?
      return alibaba_airline_code.upcase
    else
      return airline_codes.key("#{alibaba_airline_code}").to_s.upcase
    end
  end


end
