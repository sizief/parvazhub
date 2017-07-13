class SearchHistory < ApplicationRecord
  belongs_to :route

  def self.append_status(id,status)
    search_history = SearchHistory.find(id)
    search_history.update(status: search_history.status+" | "+"#{status}") 
  end
end

