# frozen_string_literal: true

require 'sidekiq-scheduler'

class TelegramMonitoringWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, backtrace: true, queue: 'critical'

  def perform(text)
    telegram = Telegram::Monitoring.new
    telegram.send(text: text)
  end
end
