class CreateSearchHistoryFlightIds < ActiveRecord::Migration[5.0]
  def change
    create_table :search_history_flight_ids do |t|
      t.integer :search_history_id  
      t.text :flight_ids      
      t.timestamps
    end
  end
end
