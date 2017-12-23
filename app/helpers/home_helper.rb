module HomeHelper

  def flight_list origin_code, destination_code
    Flight.new.get_lowest_price_collection(origin_code,destination_code)
  end

  def today_price origin_code, destination_code
    flights = flight_list origin_code,destination_code
    price = flights[:tomorrow].nil? ? nil : flights[:tomorrow].best_price
    prepare_price_message price
  end

  def prepare_price_message price
    if price.nil?
      message = "پر شد"
    else
      message = number_with_delimiter price
      message += " "+"تومان"
      
    end
  end

end