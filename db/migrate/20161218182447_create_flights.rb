class CreateFlights < ActiveRecord::Migration[5.0]
  def change
    create_table :flights do |t|
      t.integer :route_id
      t.string :flight_number
      t.datetime :deaprture_time
      t.string :airline_name

      t.timestamps
    end
  end
end
