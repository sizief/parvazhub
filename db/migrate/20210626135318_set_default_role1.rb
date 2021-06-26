class SetDefaultRole1 < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :role, "basic"
  end
end
