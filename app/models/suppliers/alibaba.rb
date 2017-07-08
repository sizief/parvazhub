class Suppliers::Alibaba
  require "open-uri"



  def search(origin,destination,date)
    #RestClient.proxy = 'http://125.162.26.193:53281'
    #proxy = '125.162.26.193:53281'
    if Rails.env.test?
        response = File.read("test/fixtures/files/domestic-alibaba.log") 
        return {response: response}
    end

    search_flight_url = "http://www.alibaba.ir/api/searchFlight?"
    get_flight_url = "https://www.alibaba.ir/api/GetFlight?"
    shamsi_date = date.to_date.to_parsi   

    begin
      search_flight_params = "ffrom=#{origin.upcase}&fto=#{destination.upcase}&datefrom=#{shamsi_date}&adult=1&child=0&infant=0"
      search_url = search_flight_url+search_flight_params
      #first_response = RestClient.get("#{search_url}")
      first_response = RestClient::Request.execute(method: :get, url: "#{search_url}", proxy: Proxy.new_proxy)
      
    rescue 
      return false
    end

    request_id = JSON.parse(first_response)["RequestId"]
    get_flight_params = "id=#{request_id}&last=0&ffrom=#{origin}&fto=#{destination}&datefrom=#{shamsi_date}&count=1&interval=1&isReturn=false&isNew=true"
    flight_url = get_flight_url+get_flight_params
    #second_response = RestClient.get("#{flight_url}")
    second_response = RestClient::Request.execute(method: :get, url: "#{flight_url}", proxy: Proxy.new_proxy)
    return {response: second_response}
  end

  def import_domestic_flights(response,route_id,origin,destination,date)
      flight_prices = Array.new()
      json_response = JSON.parse(response[:response])
      json_response["AvailableFlights"].each do |flight|
        next if flight["ClassCount"] == 0 #Alibaba send a soldout seats too. 
        flight_number = airline_code = airplane_type = departure_date_time  = nil
        corrected_airline_code = airline_code_correction(flight["AirLineEnglish"])
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
      
        flight_id = Flight.create_or_find_flight(route_id,flight_number,departure_time,airline_code,airplane_type)

        deeplink_url = "https://alibaba.ir/flights/#{origin}-#{destination}/#{date}/1-0-0" #create alibaba based on one search

        unless price == 0 #Alibaba send a soldout seats. check here to avoid import sold out tickets
          flight_price_so_far = flight_prices.select {|flight_price| flight_price.flight_id == flight_id}
          unless flight_price_so_far.empty? #check to see a flight price for given flight is exists
            if flight_price_so_far.first.price.to_i <= price.to_i #exist price is cheaper or equal to new price so ignore it
              next
            else
              flight_price_so_far.first.price = price #new price is cheaper, so update the old price and go to next price
              next
            end
          end
          flight_prices << FlightPrice.new(flight_id: "#{flight_id}", price: "#{price}", supplier:"alibaba", flight_date:"#{departure_date}", deep_link:"#{deeplink_url}")
        end
      end #end of each loop
      
      # first we should remove the old flight price archive 
      FlightPrice.delete_old_flight_prices("alibaba",route_id,date) unless flight_prices.empty?
      # then bulk import enabled by a bulk import gem
      FlightPrice.import flight_prices
      FlightPriceArchive.import flight_prices
  end

  def airline_code_correction(alibaba_airline_code)
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