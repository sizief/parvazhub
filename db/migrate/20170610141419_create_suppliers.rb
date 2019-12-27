# frozen_string_literal: true

class CreateSuppliers < ActiveRecord::Migration[5.0]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :class
      t.boolean :status

      t.timestamps
    end
  end
end
