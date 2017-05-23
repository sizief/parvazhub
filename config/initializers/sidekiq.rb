Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS'], password: ENV["REDIS_PASSWORD"]}
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS'], password: ENV["REDIS_PASSWORD"]}
end

#SearchWorker.perform_in(5.seconds,'thr','mhd',"2017-05-29")