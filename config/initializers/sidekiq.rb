Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS']}
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS']}
end

#SearchWorker.perform_in(5.seconds,'thr','mhd',"2017-05-29")