# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :route

  def self.price_alert_register(route_id, date, email)
    type = 'price_alert'
    Notification.create(route_id: route_id, date: date, email: email, notification_type: type, status: true)
  end
end
