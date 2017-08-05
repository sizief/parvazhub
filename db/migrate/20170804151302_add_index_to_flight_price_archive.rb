class AddIndexToFlightPriceArchive < ActiveRecord::Migration[5.0]
  def change
     add_index :flight_price_archives, [:flight_id, :flight_date]
  end
end
