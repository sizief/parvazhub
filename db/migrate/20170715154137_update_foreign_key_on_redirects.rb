class UpdateForeignKeyOnRedirects < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :redirects, :flight_prices
    add_foreign_key :redirects, :flight_price_archives
  end
end
