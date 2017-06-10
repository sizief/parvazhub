class RenameClassColumn < ActiveRecord::Migration[5.0]
  def change
  	rename_column :suppliers, :class, :class_name
  end
end
