# frozen_string_literal: true

class AddColumnToSearchFlightId < ActiveRecord::Migration[5.0]
  def change
    add_column :search_flight_ids, :token, :string
  end
end
