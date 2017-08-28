class CreateTelegramUsersTable < ActiveRecord::Migration[5.0]
  def change
    create_table :telegram_users do |t|
      t.string :telegram_id
      t.string :first_name
      t.string :last_name
      t.string :username
    end
    add_index :telegram_users, :telegram_id, unique: true
  end
end
