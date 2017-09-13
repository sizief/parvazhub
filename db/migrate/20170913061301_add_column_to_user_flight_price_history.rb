class AddColumnToUserFlightPriceHistory < ActiveRecord::Migration[5.0]
  def change
    add_column :user_flight_price_histories, :channel, :string    
  end
end
