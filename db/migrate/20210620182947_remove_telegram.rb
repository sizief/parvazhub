class RemoveTelegram < ActiveRecord::Migration[5.2]
  def change
    drop_table :telegram_search_queries
    drop_table :telegram_update_ids
  end
end
