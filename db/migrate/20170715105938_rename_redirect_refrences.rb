class RenameRedirectRefrences < ActiveRecord::Migration[5.0]
  def change
    rename_column :redirects, :flight_price_id, :flight_price_archive_id
  end
end
