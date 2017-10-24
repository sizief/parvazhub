class FlightPriceArchive < ApplicationRecord
  validate :check_validation
  
  def check_validation
    date = ( created_at || DateTime.now.new_offset(0)).to_date
    if self.class.exists? ["DATE(created_at) = DATE(?) AND flight_id = ? AND flight_date=?", date, flight_id, flight_date]
      errors.add :flight_id, "is not unique for #{date}"
    end
  end


  def self.flight_price_over_time(flight_id,flight_date)
    price_time = Hash.new
    flight_prices = FlightPriceArchive.where(flight_id: flight_id, flight_date: flight_date).order(:created_at)
    flight_prices.each do |flight_price|
      flight_date = flight_price.created_at.to_date.to_s
      if price_time[flight_date.to_sym].nil?
        price_time[flight_date.to_sym] = flight_price.price
      else
        price_time[flight_date.to_sym] = flight_price.price if price_time[flight_date.to_sym] > flight_price.price
      end
    end
    return price_time

  end

  def self.archive(flight_prices)

    flight_prices.each do |flight_price|
      flight_price.deep_link = nil

      archived_flight_price = FlightPriceArchive.where(flight_id: flight_price.flight_id, flight_date: flight_price.flight_date).where("created_at >?",DateTime.now.new_offset(0).to_date)
      if archived_flight_price.empty?
         FlightPriceArchive.import Array.new(1,flight_price)
      else
        if flight_price.price < archived_flight_price.first.price 
          archived_flight_price.first.delete
          FlightPriceArchive.import Array.new(1,flight_price)
        end
      end  

    end

  end

end
