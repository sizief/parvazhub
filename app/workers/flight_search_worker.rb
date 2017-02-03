class FlightSearchWorker
  include Sidekiq::Worker  
  # sidekiq_options retry: false
  
  def perform(origin,destination,route_id,date)
  	search = SearchController.new
    search.search_suppliers(origin,destination,route_id,date)
  end
end