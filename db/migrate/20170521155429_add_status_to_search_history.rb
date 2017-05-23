class AddStatusToSearchHistory < ActiveRecord::Migration[5.0]
  def change
  	add_column :search_histories, :status, :string
  end
end