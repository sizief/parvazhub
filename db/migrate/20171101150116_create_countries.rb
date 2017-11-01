class CreateCountries < ActiveRecord::Migration[5.0]
  def change
    create_table :countries do |t|

      t.string :english_name
      t.string :persian_name 
      t.string :country_code
      t.string :continent_code
      t.string :wikipedia_link
      t.timestamps
    end
  end
end


