class AddAirplane < ActiveRecord::Migration[5.0]
  def change
  	add_column :flights, :airplane_type, :string
  end
end
