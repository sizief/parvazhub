module HomeHelper

  def tomorrow_price route
    flight = Flight.new.get_lowest_price(route,Date.today+1)
    prepare_price_message flight
  end

  def prepare_price_message flight
    if flight.nil?
      message = "پر شد"
    else
      message = number_with_delimiter flight.best_price
      message += " "+"تومان"
      
    end
  end

end