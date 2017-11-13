class AddColumnToRoute < ActiveRecord::Migration[5.0]
  def change
    add_column :routes, :international, :boolean
  end
end
