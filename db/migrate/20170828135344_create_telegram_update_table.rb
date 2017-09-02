class CreateTelegramUpdateTable < ActiveRecord::Migration[5.0]
  def change
    create_table :telegram_update_ids do |t|
      t.string :update_id
    end
  end
end
