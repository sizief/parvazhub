class CreateRouteDays < ActiveRecord::Migration[5.0]
  def change
    create_table :route_days do |t|
      t.references :route, foreign_key: true
      t.integer :day_code
      t.timestamps
    end
  end
end
