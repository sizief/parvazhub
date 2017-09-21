require 'sidekiq-scheduler'

class RouteDayWorker
  include Sidekiq::Worker

  def perform
    Timeout.timeout(240) do
      route_day = RouteDay.new
      route_day.calculate_all
    end
  end

end