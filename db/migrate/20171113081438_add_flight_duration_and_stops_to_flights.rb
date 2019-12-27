# frozen_string_literal: true

class AddFlightDurationAndStopsToFlights < ActiveRecord::Migration[5.0]
  def change
    add_column :flights, :trip_duration, :integer
    add_column :flights, :stops, :string
  end
end
