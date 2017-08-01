class AddIndexToFlightDetails < ActiveRecord::Migration[5.0]
  def change
    add_index :flight_details, [:call_sign, :departure_time]
  end
end
