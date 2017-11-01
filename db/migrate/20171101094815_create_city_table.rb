class CreateCityTable < ActiveRecord::Migration[5.0]
  def change
    create_table :cities do |t|
      t.string :english_name
      t.string :persian_name 
      t.string :latitude_deg
      t.string :longitude_deg
      t.string :country_code
      t.string :region_code
      t.string :city_code
      t.string :home_link
      t.string :wikipedia_link
      t.integer :priority
      t.string :status
      t.timestamps
    end
  end
end



