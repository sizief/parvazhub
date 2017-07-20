source 'https://rubygems.org'

gem 'dotenv-rails', groups: [:development,:test,:production,:local]
gem 'rails',        '5.0.0.1'
gem 'puma',         '3.6.0'
gem 'sass-rails',   '5.0.6'
gem 'uglifier',     '3.0.0'
gem 'coffee-rails', '4.2.1'
gem 'jquery-rails', '4.1.1'
gem 'turbolinks',   '5.0.1'
gem 'jbuilder',     '2.4.1'
gem 'bcrypt',         '3.1.11'
gem 'parsi-date', '~> 0.3.1'
gem 'rest-client'
gem 'semantic-ui-sass', '~> 2.2', '>= 2.2.1.1'
gem 'pg', '~> 0.18.4'
gem "activerecord-import", ">= 0.2.0"
gem 'sidekiq'
gem 'redis-rails'
gem 'sidekiq-scheduler'
gem 'scout_apm'
gem 'sidekiq-status'
gem 'devise'


group :development do
  gem 'web-console',           '3.1.1'
  gem 'listen',                '3.0.8'
  gem 'spring',                '1.7.2'
  gem 'spring-watcher-listen', '2.0.0'
  gem 'byebug',  '9.0.0', platform: :mri
  gem 'simplecov', :require => false, :group => :test
end

group :test do
  gem 'rails-controller-testing', '0.1.1'
  gem 'minitest-reporters',       '1.1.9'
  gem 'guard',                    '2.13.0'
  gem 'guard-minitest',           '2.4.4'
  gem 'sqlite3', '1.3.12'
end

group :production do
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
