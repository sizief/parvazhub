class FlightInfo < ApplicationRecord
    validates :flight_id, :uniqueness => true
    belongs_to :flight

    def calculate_info
      domestic_routes=Route.select(:id).where(international: false)
      flights = Flight.where(route_id: domestic_routes).where(['departure_time >= ?', Date.today.to_datetime])
      flights.each do |flight|
        if flight.flight_info.nil?
            create_flight_info(flight)
        else
            update_flight_info(flight)
        end
      end
    end

    def create_flight_info(flight)
      response = prepare_flight_info(flight)
      FlightInfo.create(flight_id: flight.id, call_sign: response[:call_sign], airplane: response[:airplane], delay: response[:delay], canceled: response[:canceled], weekly_delay: response[:weekly_delay])
    end

    def update_flight_info(flight)
      response = prepare_flight_info(flight)
      flight.flight_info.update_attributes(flight_id:flight.id, call_sign:response[:call_sign], airplane: response[:airplane], delay:response[:delay], canceled:response[:canceled], weekly_delay: response[:weekly_delay])
    end

    def prepare_flight_info(flight)
      call_sign = Flight.new.get_call_sign(flight.flight_number,flight.airline_code)
      flight_details = FlightDetail.where(call_sign: call_sign)
      airplane = flight.airplane_type
      delay = canceled = nil
      
      unless flight_details.empty?
        airplane = flight_details.last.airplane_type unless flight_details.last.airplane_type.nil?
        delay = calculate_delay_based_on_flight_number(flight_details)
        weekly_delay = calculate_delay_based_on_week(flight_details, flight.departure_time.to_date) 
        #canceled = should count "باطل شده"
      end

      return {call_sign: call_sign,airplane: airplane,delay: delay,canceled: canceled, weekly_delay: weekly_delay}
    end

    def calculate_delay_based_on_flight_number (flight_details)
      delay = Array.new
      flight_details.each do |flight_detail|
        unless flight_detail.actual_departure_time.nil?
          delay << ((flight_detail.actual_departure_time.to_datetime - flight_detail.departure_time.to_datetime)*24*60).to_i
        end
      end 
      if delay.empty? 
        return nil 
      else
        return (delay.sum.to_f / delay.size).round
      end
    end

    def calculate_delay_based_on_week (flight_details,date)
      delay = Array.new
      flight_details.each do |flight_detail|
        unless flight_detail.actual_departure_time.nil?
          is_happend_week_ago = (date - flight_detail.departure_time.to_date).round % 7
          if is_happend_week_ago == 0
            delay << ((flight_detail.actual_departure_time.to_datetime - flight_detail.departure_time.to_datetime)*24*60).to_i
          end
        end
      end 
      if delay.empty? 
        return nil 
      else
        return (delay.sum.to_f / delay.size).round
      end
    end

    def canceled_count (call_sign,departure_time)
    end

end
