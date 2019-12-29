# frozen_string_literal: true

app_dir = File.expand_path('..', __dir__)
shared_dir = "#{app_dir}/tmp"

# Default to production
rails_env = ENV['RAILS_ENV'] || 'production'
environment rails_env

# Set up socket location
bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
# stdout_redirect "log/puma.stdout.log", "log/puma.stderr.log", true if rails_env == 'production'

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

threads_count = ENV['RAILS_ENV'] == 'development' ? 1 : ENV.fetch('RAILS_MAX_THREADS') { 5 }.to_i
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
#
port ENV.fetch('PORT') { 3000 }

workers ENV['RAILS_ENV'] == 'development' ? 1 : ENV.fetch('WEB_CONCURRENCY') { 8 }

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
