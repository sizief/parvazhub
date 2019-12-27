# frozen_string_literal: true

class AddColumnsToRedirect < ActiveRecord::Migration[5.0]
  def change
    add_column :redirects, :user_agent, :string
    add_column :redirects, :remote_ip, :string
  end
end
