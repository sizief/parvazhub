class AddDepartureTime < ActiveRecord::Migration[5.0]
  def change
  	add_column :search_histories, :departure_time, :string
  end
end
