# frozen_string_literal: true

class RemoveDepartureTimeFromFlightInfo < ActiveRecord::Migration[5.0]
  def change
    remove_column :flight_infos, :departure_time
  end
end
