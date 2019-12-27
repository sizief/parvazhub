# frozen_string_literal: true

class AddIndexToFlightPrice < ActiveRecord::Migration[5.0]
  def change
    add_index :flight_prices, %i[flight_id flight_date]
  end
end
