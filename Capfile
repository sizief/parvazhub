# frozen_string_literal: true

# Load DSL and set up stages
require 'capistrano/setup'
require 'dotenv'
require 'capistrano/env-config'

# Include default deployment tasks
require 'capistrano/deploy'
require 'capistrano/rbenv'
require 'capistrano/rails'
require 'capistrano/bundler'
# require 'capistrano/puma'
require 'capistrano/rails/assets'

# config/deploy.rb
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.6.5'
set :rbenv_path, '/home/sizief/.rbenv/' # /usr/bin/rbenv
set :bundle_path, '/home/sizief/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0'

# in case you want to set ruby version from the file:
set :rbenv_ruby, File.read('.ruby-version').strip

set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w[rake gem bundle ruby rails]
set :rbenv_roles, :all # default value

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
