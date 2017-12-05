class AddColumnToFlightPrices < ActiveRecord::Migration[5.0]
  def change
    add_column :flight_prices, :is_deep_link_url, :boolean, default: true         
  end
end
