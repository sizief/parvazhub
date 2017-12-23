require 'sidekiq-scheduler'

class FlightInfoWorker
  include Sidekiq::Worker

  def perform
    Timeout.timeout(900) do
      x = FlightInfo.new
      x.calculate_info
    end
  end

end