class UpdateUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :encrypted_password
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at
    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :telegram_id
    remove_column :users, :channel

    add_column :users, :locale, :string
    add_column :users, :avatar_url, :string
    add_column :users, :google_user_id, :string, :uniqueness => true
  end
end
