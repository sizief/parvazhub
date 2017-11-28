class SearchFlightId < ApplicationRecord

  def self.get_ids token
    flight_ids = Array.new
    search_histories = SearchFlightId.select(:flight_ids).where(token: token)
    search_histories.each do |search_history| 
      next if search_history.flight_ids.nil?
      flight_ids << search_history.flight_ids.tr('[]', '').split(',').map(&:to_i)
    end
    flight_ids.flatten.uniq         
  end
  
end
