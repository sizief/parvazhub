class AddRateToSupplier < ActiveRecord::Migration[5.0]
  def change
    add_column :suppliers, :rate_count, :integer
    add_column :suppliers, :rate_average, :integer
  end
end
