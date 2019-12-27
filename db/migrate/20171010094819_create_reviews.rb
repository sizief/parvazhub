# frozen_string_literal: true

class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
      t.string :author
      t.string :page
      t.text :text
      t.integer :rate
      t.string :status
      t.integer :reply_to
      t.timestamps
    end
  end
end
