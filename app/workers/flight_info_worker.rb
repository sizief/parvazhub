# frozen_string_literal: true

require 'sidekiq-scheduler'

class FlightInfoWorker
  include Sidekiq::Worker

  def perform
    Timeout.timeout(1800) do
      x = FlightInfo.new
      x.calculate_info
    end
  end
end
