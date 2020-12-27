# frozen_string_literal: true

class FlightPrice < ApplicationRecord
  belongs_to :flight, counter_cache: true

  def self.delete_old_flight_prices(route, date)
    ids = Flight
          .where(route_id: route.id)
          .where(departure_time: date.to_datetime.beginning_of_day.to_s..date.to_datetime.end_of_day.to_s)
          .ids
    FlightPrice.where(flight_id: ids).where(flight_date: date.to_s).delete_all
  end

  def get(flight_id, result_time_to_live)
    responses = []
    suppliers_list = FlightPrice.select(:id, :flight_id, :price, :supplier, :created_at).where(flight_id: flight_id)
                                .where('created_at >= ?', result_time_to_live)
                                .order(:price)
    suppliers_list.each do |supplier|
      response = {}
      response[:id] = supplier.id
      response[:flight_id] = supplier.flight_id
      response[:price] = supplier.price
      response[:price_dollar] = to_dollar(supplier.price)
      response[:supplier_english_name] = supplier.supplier
      response[:created_at] = supplier.created_at
      response[:supplier_persian_name] = supplier_persian_name supplier.supplier
      response[:supplier_logo] = supplier_logo supplier.supplier
      responses << response
    end
    responses
  end

  private

  def supplier_logo(supplier_name)
    Supplier.new.get_logo supplier_name
  end

  def supplier_persian_name(supplier_name)
    Supplier.new.get_persian_name supplier_name
  end

  def to_dollar(amount)
    Currency.new.to_dollar amount
  end
end
