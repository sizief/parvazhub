class DeleteSearchFlightId < ActiveRecord::Migration[5.2]
  def change
    drop_table :search_flight_ids
  end
end
