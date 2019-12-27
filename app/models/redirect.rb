# frozen_string_literal: true

class Redirect < ApplicationRecord
  belongs_to :user

  def migrate_drop_flight_price_archive
    Redirect.all.each do |redirect|
      flight_price_archive = FlightPriceArchive.find(redirect.flight_price_archive_id)
      redirect.flight_id = flight_price_archive.flight_id
      redirect.price = flight_price_archive.price
      redirect.supplier = flight_price_archive.supplier
      redirect.deep_link = flight_price_archive.deep_link
      redirect.save
    rescue StandardError
      next
    end
  end
end
