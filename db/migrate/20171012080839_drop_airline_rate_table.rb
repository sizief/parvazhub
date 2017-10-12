class DropAirlineRateTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :airline_rates
  end
end
