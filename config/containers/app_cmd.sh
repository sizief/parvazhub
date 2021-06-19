#!/usr/bin/env bash

if [ "$ENTRYPOINT" = "app" ]
then
  bundle exec rails db:migrate;
  bundle exec rake assets:precompile;
  ruby config/version_updater.rb
  bundle exec puma -C config/containers/puma.rb;
elif [ "$ENTRYPOINT" = "sidekiq" ]
then
  exec bundle exec sidekiq #-r app/workers/search_worker.rb #-L log/sidekiq.log
fi
