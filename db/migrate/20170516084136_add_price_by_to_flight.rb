class AddPriceByToFlight < ActiveRecord::Migration[5.0]
  def change
  	add_column :flights, :price_by, :string
  end
end
