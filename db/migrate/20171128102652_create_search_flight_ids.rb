class CreateSearchFlightIds < ActiveRecord::Migration[5.0]
  def change
    create_table :search_flight_ids do |t|
      t.text :flight_ids      
    end
  end
end
