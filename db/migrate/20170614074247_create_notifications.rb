class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.references :route, foreign_key: true
      t.string :date
      t.string :email
      t.string :type

      t.timestamps
    end
  end
end
