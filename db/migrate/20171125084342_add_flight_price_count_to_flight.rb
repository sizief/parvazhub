# frozen_string_literal: true

class AddFlightPriceCountToFlight < ActiveRecord::Migration[5.0]
  def change
    add_column :flights, :flight_prices_count, :integer
  end
end
