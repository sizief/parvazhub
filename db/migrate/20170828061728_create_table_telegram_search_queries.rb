class CreateTableTelegramSearchQueries < ActiveRecord::Migration[5.0]
  def change
    create_table :telegram_search_queries do |t|
      t.references :telegram_user, foreign_key: true
      t.string :origin
      t.string :destination
      t.string :date
      t.string :flight_price
    end
  end
end
