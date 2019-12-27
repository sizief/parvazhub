# frozen_string_literal: true

require 'sidekiq-scheduler'

class UserFlightPriceHistoryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true, queue: 'low'

  def perform(channel, flight_id, user_id)
    Timeout.timeout(60) do
      UserFlightPriceHistory.create(flight_id: flight_id, channel: channel, user_id: user_id)
    end
  end
end
