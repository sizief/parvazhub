class Airline < ApplicationRecord
  validates :code, :uniqueness => true

  def self.persian_hash_list 
    airline_list = Hash.new
    Airline.all.each do |airline|
        airline_list[airline.code.to_sym] = airline.persian_name
    end
    return airline_list
  end

  def self.english_hash_list 
    airline_list = Hash.new
    Airline.all.each do |airline|
        airline_list[airline.code.to_sym] = airline.persian_name
    end
    return airline_list
  end

  def update_rates
    Airline.all.each do |airline|
      rate_sum = Review.where(page: airline.english_name).sum("rate")    
      rate_count = Review.where(page: airline.english_name).where.not(rate: nil).count
      rate_average = rate_count == 0 ? 0 : (rate_sum.to_f/rate_count).round
      
      airline.rate_average = rate_average
      airline.rate_count = rate_count
      airline.save 
    end  
  end
  
end
