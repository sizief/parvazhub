require 'sidekiq-scheduler'

class FlightInfoWorker
  include Sidekiq::Worker

  def perform
    x = FlightInfo.new
    x.calculate_info
  end

end