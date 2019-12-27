# frozen_string_literal: true

class AddColumnToProxy < ActiveRecord::Migration[5.0]
  def change
    add_column :proxies, :status, :string
  end
end
