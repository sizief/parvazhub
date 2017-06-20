class CreateRedirects < ActiveRecord::Migration[5.0]
  def change
    create_table :redirects do |t|
      t.references :flight_price, foreign_key: true	
      t.timestamps
    end
  end
end
