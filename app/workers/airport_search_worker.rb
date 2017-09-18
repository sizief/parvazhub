require 'sidekiq-scheduler'

class AirportSearchWorker
  include Sidekiq::Worker
  
  def perform
    airport_search = Airports::DomesticAirport.new
    Airports::DomesticAirport.airports.each do |airport|
      results = airport_search.search(airport[0])
      airport_search.import_domestic_flights(results,airport[1])
    end

    Airports::DomesticAirport.unnormal_airport.each do |airport|
      airport_search = airport[2].constantize.new
      results = airport_search.search(airport[0])
      airport_search.import_domestic_flights(results,airport[1])
    end


  end

end