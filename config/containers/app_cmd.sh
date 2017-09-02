#!/usr/bin/env bash

# Prefix `bundle` with `exec` so unicorn shuts down gracefully on SIGTERM (i.e. `docker stop`)
#exec bundle exec unicorn -c config/containers/unicorn.rb -E $RAILS_ENV;
#exec bundle exec puma -C config/containers/puma.rb; 
#bundle exec sidekiq #-r app/workers/search_worker.rb #-L log/sidekiq.log

if [ "$ENTRYPOINT" = "app" ]
then
  exec bundle exec puma -C config/containers/puma.rb; 

elif [ "$ENTRYPOINT" = "background_job" ]
then
  exec bundle exec sidekiq #-r app/workers/search_worker.rb #-L log/sidekiq.log

fi