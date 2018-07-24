class AddRateToSuppliers < ActiveRecord::Migration[5.0]
  def change
    add_column :suppliers, :rate_count, :integer
    add_column :suppliers, :rate_average, :integer
    add_index :suppliers, [:name],  unique: true  
  end
end
