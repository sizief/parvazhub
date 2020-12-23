# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

module FlightSearch
  class Application < Rails::Application
    config.middleware.use Rack::Deflater
    config.i18n.default_locale = :en
    config.assets.enabled = true
  end
end

Sentry.init do |config|
  config.dsn = 'https://3223b53cbeba430faf119a09dba0f99d@o495243.ingest.sentry.io/5567670'
  config.breadcrumbs_logger = [:active_support_logger]

  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  config.traces_sample_rate = 0.5
  config.enabled_environments = %w[production]
end
