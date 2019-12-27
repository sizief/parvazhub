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
