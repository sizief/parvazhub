class AddMetadataToProxy < ActiveRecord::Migration[5.2]
  def change
    add_column :proxies, :metadata, :text
  end
end
