# frozen_string_literal: true

require 'sidekiq-scheduler'

class ReviewRateWorker
  include Sidekiq::Worker

  def perform
    Airline.new.update_rates
    Supplier.new.update_rates
  end
end
