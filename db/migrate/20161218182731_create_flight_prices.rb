# frozen_string_literal: true

class CreateFlightPrices < ActiveRecord::Migration[5.0]
  def change
    create_table :flight_prices do |t|
      t.integer :flight_id
      t.integer :price
      t.string :supplier

      t.timestamps
    end
  end
end
