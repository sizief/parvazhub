# frozen_string_literal: true

class ChangeActualDapartureTimeToActualDepartureTimeFromFlightDetails < ActiveRecord::Migration[5.0]
  def change
    rename_column :flight_details, :actual_daparture_time, :actual_departure_time
  end
end
