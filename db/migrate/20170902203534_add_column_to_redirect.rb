# frozen_string_literal: true

class AddColumnToRedirect < ActiveRecord::Migration[5.0]
  def change
    add_column :redirects, :channel, :string
  end
end
