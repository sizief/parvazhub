# frozen_string_literal: true

class AddColumnToNotification < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :status, :boolean
  end
end
