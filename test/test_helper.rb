# frozen_string_literal: true

require 'simplecov'
require 'active_record'
SimpleCov.start 'rails'
ActiveRecord::Migration.maintain_test_schema!

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  ENV['MAX_NUMBER_FLIGHT'] = '1000'

  # Add more helper methods to be used by all tests here...
end
