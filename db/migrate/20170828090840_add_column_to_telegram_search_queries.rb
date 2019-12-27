# frozen_string_literal: true

class AddColumnToTelegramSearchQueries < ActiveRecord::Migration[5.0]
  def change
    add_column :telegram_search_queries, :chat_id, :string
  end
end
