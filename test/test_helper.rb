# frozen_string_literal: true

require 'simplecov'
require 'active_record'
require 'rubygems'
require 'test/unit'
require 'vcr'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'

ENV['RAILS_ENV'] ||= 'test'

SimpleCov.start 'rails'
ActiveRecord::Migration.maintain_test_schema!

class ActiveSupport::TestCase
  fixtures :all
  ENV['MAX_NUMBER_FLIGHT'] = '1000'
  VCR.configure do |config|
    config.cassette_library_dir = "test/fixtures/vcr_cassettes"
    config.hook_into :webmock
  end

end
