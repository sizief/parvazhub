# frozen_string_literal: true

class AddCountryCodeToAirlines < ActiveRecord::Migration[5.0]
  def change
    add_column :airlines, :country_code, :string
  end
end
