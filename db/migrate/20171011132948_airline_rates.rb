class AirlineRates < ActiveRecord::Migration[5.0]
  def change
    create_table :airline_rates do |t|
      t.string :code
      t.integer :average
      t.integer :count
      t.timestamps
    end
  end
end
