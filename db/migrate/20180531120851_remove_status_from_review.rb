class RemoveStatusFromReview < ActiveRecord::Migration[5.0]
  def change
    remove_column :reviews, :status
  end
end
