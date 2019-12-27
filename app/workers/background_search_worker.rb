# frozen_string_literal: true

require 'sidekiq-scheduler'

class BackgroundSearchWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0, backtrace: true

  def perform(args)
    search_hourly(args['date_offset']) if args['type'].nil?
    search_daily if args['type'] == 'daily'
  end

  private

  def search_daily
    routes = MostSearchRoute.new.get(ENV['FIRST_PAGE_OFFERS'].to_i)
    0.upto(21) do |date_offset|
      date = (Date.today + date_offset.to_f).to_s
      search routes, date
      sleep 5
    end
  end

  def search_hourly(date_offset)
    routes = MostSearchRoute.new.get 5
    date = (Date.today + date_offset.to_f).to_s
    search routes, date
  end

  def search(routes, date)
    routes.each do |route|
      timeout = route.route.international? ? ENV['TIMEOUT_INTERNATIONAL'].to_i : ENV['TIMEOUT_DOMESTIC'].to_i
      SupplierSearch.new(origin: route.route[:origin],
                         destination: route.route[:destination],
                         date: date,
                         timeout: timeout,
                         search_initiator: 'job_search').search
      break if Rails.env.test?
    end
  end
end
