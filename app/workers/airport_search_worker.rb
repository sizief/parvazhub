require 'sidekiq-scheduler'

class AirportSearchWorker
  include Sidekiq::Worker
  @@airport_list = [
        {class: Airports::Mashhad,name: "Mashhad"},
        {class: Airports::Mehrabad,name: "Mehrabad"}
      ]

  def perform
    @@airport_list.each do |airport| 
      flights = airport[:class].new
      list = flights.search
      flights.import_domestic_flights list  
  	end
  end

end