class AddColumnToRedirects < ActiveRecord::Migration[5.0]
  def change
    add_column :redirects, :flight_id, :integer
    add_column :redirects, :price, :integer
    add_column :redirects, :supplier, :string
    add_column :redirects, :deep_link, :string 
  end
end
