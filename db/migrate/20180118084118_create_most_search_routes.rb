# frozen_string_literal: true

class CreateMostSearchRoutes < ActiveRecord::Migration[5.0]
  def change
    create_table :most_search_routes do |t|
      t.references :route, foreign_key: true
      t.integer :count
      t.timestamps
    end
  end
end
