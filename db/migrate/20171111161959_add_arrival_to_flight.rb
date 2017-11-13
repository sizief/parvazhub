class AddArrivalToFlight < ActiveRecord::Migration[5.0]
  def change
    add_column :flights, :arrival_date_time, :datetime
  end
end
