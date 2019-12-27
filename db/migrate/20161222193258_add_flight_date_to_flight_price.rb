# frozen_string_literal: true

class AddFlightDateToFlightPrice < ActiveRecord::Migration[5.0]
  def change
    add_column :flight_prices, :flight_date, :date
  end
end
