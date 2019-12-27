# frozen_string_literal: true

class AddIndexToSearchFlightIds < ActiveRecord::Migration[5.0]
  def change
    add_index :search_flight_ids, [:token]
  end
end
