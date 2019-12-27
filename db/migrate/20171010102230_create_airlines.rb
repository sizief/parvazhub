# frozen_string_literal: true

class CreateAirlines < ActiveRecord::Migration[5.0]
  def change
    create_table :airlines do |t|
      t.string :english_name
      t.string :persian_name
      t.string :code
      t.timestamps
    end
  end
end
