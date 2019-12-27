# frozen_string_literal: true

class DropTelegramUsers < ActiveRecord::Migration[5.0]
  def change
    drop_table :telegram_users
  end
end
