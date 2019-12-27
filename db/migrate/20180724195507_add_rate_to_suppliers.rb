# frozen_string_literal: true

class AddRateToSuppliers < ActiveRecord::Migration[5.0]
  def change
    add_index :suppliers, [:name], unique: true
  end
end
