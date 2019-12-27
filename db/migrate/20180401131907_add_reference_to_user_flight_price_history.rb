# frozen_string_literal: true

class AddReferenceToUserFlightPriceHistory < ActiveRecord::Migration[5.0]
  def change
    add_reference :user_flight_price_histories, :user, index: true, foreign_key: true
  end
end
