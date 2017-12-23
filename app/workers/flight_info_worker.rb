require 'sidekiq-scheduler'

class FlightInfoWorker
  include Sidekiq::Worker

  def perform
    Timeout.timeout(600) do
      x = FlightInfo.new
      x.calculate_info
    end
  end

end