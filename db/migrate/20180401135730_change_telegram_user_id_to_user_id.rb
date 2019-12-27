# frozen_string_literal: true

class ChangeTelegramUserIdToUserId < ActiveRecord::Migration[5.0]
  def change
    remove_column :telegram_search_queries, :telegram_user_id
    add_reference :telegram_search_queries, :user, index: true, foreign_key: true
  end
end
