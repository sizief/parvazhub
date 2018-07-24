class AddUserToReview < ActiveRecord::Migration[5.0]
  def change
    add_reference :reviews, :user, index: true, foreign_key: true
    add_column :reviews, :category, :integer, :default => 0
  end
end
