class AddDefaultForEnableProxies < ActiveRecord::Migration[5.2]
  def change
    remove_column :proxies, :status
    add_column :proxies, :enable, :boolean, default: true
  end
end
