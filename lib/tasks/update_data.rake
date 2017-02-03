desc "Update flight price data"
task :update_data => :environment do
  puts "Reading supplier data"
  FlightSearchWorker.perform_async("thr","mhd","18","2017-02-04")
  puts "done."
end