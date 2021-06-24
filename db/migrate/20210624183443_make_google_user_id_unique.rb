class MakeGoogleUserIdUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :google_user_id, :unique => true
  end
end
