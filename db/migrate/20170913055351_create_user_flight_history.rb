# frozen_string_literal: true

class CreateUserFlightHistory < ActiveRecord::Migration[5.0]
  def change
    create_table :user_flight_price_histories do |t|
      t.string :flight_id
    end
  end
end
