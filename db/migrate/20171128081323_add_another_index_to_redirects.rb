# frozen_string_literal: true

class AddAnotherIndexToRedirects < ActiveRecord::Migration[5.0]
  def change
    add_index :redirects, [:supplier]
  end
end
