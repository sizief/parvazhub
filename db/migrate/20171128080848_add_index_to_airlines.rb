class AddIndexToAirlines < ActiveRecord::Migration[5.0]
  def change
    add_index :airlines, [:code],  unique: true    
  end
end
