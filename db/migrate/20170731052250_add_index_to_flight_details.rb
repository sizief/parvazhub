# frozen_string_literal: true

class AddIndexToFlightDetails < ActiveRecord::Migration[5.0]
  def change
    add_index :flight_details, %i[call_sign departure_time]
  end
end
