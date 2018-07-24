class Telegram::SearchQuery < ApplicationRecord
    self.table_name = "telegram_search_queries"
    validates :chat_id, :uniqueness => true
    belongs_to :user
end
