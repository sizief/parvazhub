# frozen_string_literal: true

class AddIndexToCountries < ActiveRecord::Migration[5.0]
  def change
    add_index :countries, [:country_code], unique: true
  end
end
