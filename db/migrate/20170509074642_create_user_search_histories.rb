# frozen_string_literal: true

class CreateUserSearchHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :user_search_histories do |t|
      t.integer :route_id
      t.string :departure_time

      t.timestamps
    end
  end
end
