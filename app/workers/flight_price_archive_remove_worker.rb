require 'sidekiq-scheduler'

class FlightPriceArchiveRemoveWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1, :backtrace => true
  
  def perform
    FlightPriceArchive.where("created_at < ?",Date.today-15).where.not("id IN (#{Redirect.select("flight_price_archive_id").to_sql})").delete_all
  end

end