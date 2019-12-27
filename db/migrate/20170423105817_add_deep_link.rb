# frozen_string_literal: true

class AddDeepLink < ActiveRecord::Migration[5.0]
  def change
    add_column :flight_prices, :deep_link, :string
  end
end
