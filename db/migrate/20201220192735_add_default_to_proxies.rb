class AddDefaultToProxies < ActiveRecord::Migration[5.2]
  def change
    remove_column :proxies, :enable
    add_column :proxies, :enable, :boolean, default: true
  end
end
