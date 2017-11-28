class AddIndexToCities < ActiveRecord::Migration[5.0]
  def change
    add_index :cities, [:city_code],  unique: true  
    add_index :cities, [:english_name]        
  end
end
