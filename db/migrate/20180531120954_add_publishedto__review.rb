class AddPublishedtoReview < ActiveRecord::Migration[5.0]
  def change
    add_column :reviews, :published, :boolean, default: true
  end
end
