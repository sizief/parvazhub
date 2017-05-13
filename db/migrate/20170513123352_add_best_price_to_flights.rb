class AddBestPriceToFlights < ActiveRecord::Migration[5.0]
  def change
  	add_column :flights, :best_price, :integer
  end
end
