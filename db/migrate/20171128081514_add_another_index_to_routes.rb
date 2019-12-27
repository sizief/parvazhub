# frozen_string_literal: true

class AddAnotherIndexToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_index :routes, %i[origin destination]
  end
end
