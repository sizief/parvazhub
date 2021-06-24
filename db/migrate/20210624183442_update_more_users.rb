class UpdateMoreUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :reset_password_token
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
  end
end
