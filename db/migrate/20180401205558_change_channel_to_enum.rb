# frozen_string_literal: true

class ChangeChannelToEnum < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :channel
    add_column :users, :channel, :integer
  end
end
