class AddUniqueConstraint < ActiveRecord::Migration[5.2]
  def change
    add_index :reviews, [:user_id, :text], unique: true
  end
end
