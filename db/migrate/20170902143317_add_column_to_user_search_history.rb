class AddColumnToUserSearchHistory < ActiveRecord::Migration[5.0]
  def change
    add_column :user_search_histories, :channel, :string
  end
end
