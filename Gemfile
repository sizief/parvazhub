# frozen_string_literal: true

source 'https://rubygems.org'

gem 'activerecord'
gem 'activerecord-import', '>= 0.2.0'
gem 'bcrypt', '3.1.12'
gem 'browser'
gem 'coffee-rails'
gem 'dotenv-rails', groups: %i[development test production local]
gem 'execjs'
gem 'foreman', '~> 0.82.0'
gem 'jalalidate'
gem 'jbuilder'
gem 'pg', '~> 0.18.4'
gem 'puma', '4.3.12'
gem 'rack', '>= 2.1.4'
gem 'rails', '5.2.0'
gem 'rbzip2', '0.3.0'
gem 'redis-rails'
gem 'rest-client'
gem 'sass-rails'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'sidekiq-status'
gem 'sprockets', '4.0.2'
gem 'turbolinks', '5.0.1'
gem 'uglifier', '4.2.0'
gem 'google_sign_in'

group :development do
  gem 'listen'
  gem 'simplecov', require: false, group: :test
  gem 'web-console'
end

group :test do
  gem 'guard',                    '2.13.0'
  gem 'guard-minitest',           '2.4.4'
  gem 'minitest-reporters',       '1.1.9'
  gem 'rails-controller-testing', '0.1.1'
  gem 'test-unit', '~> 3.1', '>= 3.1.8'
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~> 3.11'
end

group :test, :development do
  gem 'pry', '~> 0.12.2'
  gem 'pry-nav'
end
