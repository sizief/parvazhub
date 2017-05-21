require 'sidekiq-scheduler'

class SearchWorker
  include Sidekiq::Worker

  def perform(origin,destination,date)
    background_search = SearchController.new()
    background_search.backgound_search_proccess(origin,destination,date)
  end
end
