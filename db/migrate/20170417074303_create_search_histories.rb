# frozen_string_literal: true

class CreateSearchHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :search_histories do |t|
      t.string :supplier_name
      t.references :route, foreign_key: true

      t.timestamps
    end
  end
end
