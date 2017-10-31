class CreateTableTemp1 < ActiveRecord::Migration[5.0]
  def change
    create_table :temp_airports do |t|
      t.string :ident
      t.string :type_airport
      t.string :name
      t.string :latitude_deg
      t.string :longitude_deg
      t.string :elevation_ft
      t.string :continent
      t.string :iso_country
      t.string :iso_region
      t.string :municipality
      t.string :scheduled_service
      t.string :gps_code
      t.string :iata_code
      t.string :local_code
      t.string :home_link
      t.string :wikipedia_link
      t.string :keywords
    end
  end
end
