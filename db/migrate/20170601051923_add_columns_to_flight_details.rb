# frozen_string_literal: true

class AddColumnsToFlightDetails < ActiveRecord::Migration[5.0]
  def change
    remove_column :flight_details, :airline_code
    add_column :flight_details, :status, :string
    add_column :flight_details, :terminal, :integer
    add_column :flight_details, :actual_daparture_time, :datetime
  end
end
