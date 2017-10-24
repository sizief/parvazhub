class RemoveFlightPriceArchiveFromRedirectTable < ActiveRecord::Migration[5.0]
  def change
    remove_column :redirects, :flight_price_archive_id    
  end
end
