class AddIndexToFlightPrice < ActiveRecord::Migration[5.0]
  def change
      add_index :flight_prices, [:flight_id, :flight_date]
  end
end
