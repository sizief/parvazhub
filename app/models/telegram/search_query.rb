class Telegram::SearchQuery < ApplicationRecord
    self.table_name = "telegram_search_queries"
    belongs_to :telegram_search_query,
            :class_name => 'Telegram::SearchQuery',
            :foreign_key => ':telegram_search_queries_id'
	
end
