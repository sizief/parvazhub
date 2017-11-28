class AddAnotherIndexToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_index :routes, [:origin, :destination]   
  end
end
