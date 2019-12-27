# frozen_string_literal: true

class AddIndexToFlightPriceArchive < ActiveRecord::Migration[5.0]
  def change
    add_index :flight_price_archives, %i[flight_id flight_date]
  end
end
