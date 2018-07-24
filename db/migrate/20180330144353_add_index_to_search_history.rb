class AddIndexToSearchHistory < ActiveRecord::Migration[5.0]
  def change
    add_index :search_histories, [:created_at, :supplier_name] 
    add_column :search_histories, :successful, :boolean
  end
end
