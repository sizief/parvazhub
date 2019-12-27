# frozen_string_literal: true

class AddColumnToAirlines < ActiveRecord::Migration[5.0]
  def change
    add_column :airlines, :rate_count, :integer
    add_column :airlines, :rate_average, :integer
  end
end
