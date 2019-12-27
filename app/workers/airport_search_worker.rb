# frozen_string_literal: true

require 'sidekiq-scheduler'

class AirportSearchWorker
  include Sidekiq::Worker

  def perform
    airport_search = Airports::DomesticAirport.new
    Airports::DomesticAirport.airports.each do |airport|
      airport_search.import(airport[0], airport[1])
    end

    Airports::DomesticAirport.unnormal_airport.each do |airport|
      airport_search = airport[2].constantize.new
      airport_search.import(airport[0], airport[1])
    end
  end
end
