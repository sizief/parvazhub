class SearchHistoryFlightId < ApplicationRecord
  validates :search_history_id, :uniqueness => true
  attr_reader :search_history_id, :flight_ids
 
  def save_or_update
    ActiveRecord::Base.connection_pool.with_connection do 
      search_history = SearchHistoryFlightId.create(search_history_id: search_history_id,flight_ids: flight_ids)
      unless search_history.id #search_history is already exists
        search_history = SearchHistoryFlightId.find_by(search_history_id: search_history_id)
        search_history.update(flight_ids: flight_ids+search_history.flight_ids)
      end
    end
  end

  def self.get_ids search_history_id
    search_history = SearchHistoryFlightId.find_by(search_history_id: search_history_id)
    search_history.flight_ids.flatten.uniq         
  end
  
end
