class Airline < ApplicationRecord
  validates :code, :uniqueness => true

  def self.list
    airline_list = Hash.new
    Airline.all.each do |airline|
        airline_list[airline.code.to_sym] = {english_name: airline.english_name,
        persian_name: airline.persian_name,
        rate_average: airline.rate_average}
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

  def get_persian_name_by_english_name english_name
    airline = Airline.find_by(english_name: english_name)
    persian_name = airline.nil? ? nil : airline.persian_name
    persian_name
  end

  
end
