require 'sidekiq-scheduler'

class AirlineRateWorker
  include Sidekiq::Worker
  
  def perform
    airline = Airline.new
    airline.update_rates
  end

end