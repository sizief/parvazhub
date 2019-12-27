# frozen_string_literal: true

class AddTelegramIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :telegram_id, :string
    add_column :users, :channel, :integer
    add_column :users, :role, :integer
  end
end
