class RemoveFlightPriceArchiveFromRedirect < ActiveRecord::Migration[5.0]
  	
  def self.down
     remove_column :redirects, :flight_price_archive_id
  end
end
