class CreateFlightPriceArchives < ActiveRecord::Migration[5.0]
  def change
    create_table :flight_price_archives do |t|
      t.integer :flight_id
      t.integer :price
      t.string :supplier
      t.date :flight_date
      t.string :deep_link
      t.timestamps
    end
  end
end
