class CreateFlightDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :flight_details do |t|
      t.integer :route_id
      t.string :flight_number
      t.datetime :departure_time
      t.string :airline_code
      t.string :airplane_type

      t.timestamps
    end
  end
end
