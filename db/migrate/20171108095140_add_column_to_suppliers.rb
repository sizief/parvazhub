class AddColumnToSuppliers < ActiveRecord::Migration[5.0]
  def change
    add_column :suppliers, :international, :boolean
    add_column :suppliers, :domestic, :boolean
  end
end
