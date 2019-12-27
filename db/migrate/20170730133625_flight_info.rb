# frozen_string_literal: true

class FlightInfo < ActiveRecord::Migration[5.0]
  def change
    create_table :flight_infos do |t|
      t.references :flight
      t.datetime :departure_time
      t.string :call_sign
      t.string :airplane
      t.string :delay
      t.string :canceled
    end
  end
end
