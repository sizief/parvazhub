# frozen_string_literal: true

class AddColumnToFlightInfo < ActiveRecord::Migration[5.0]
  def change
    add_column :flight_infos, :weekly_delay, :string
  end
end
