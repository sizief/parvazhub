class Change < ActiveRecord::Migration[5.0]
  def change
  	change_column :flights, :departure_time, :datetime
  end
end
