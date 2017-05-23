require 'sidekiq-scheduler'

class SearchWorker
  include Sidekiq::Worker
  @@origin_destination = [
  	{origin:"thr",destination:"mhd"},
  	{origin:"thr",destination:"kih"},
  	{origin:"thr",destination:"ifn"},
  	{origin:"thr",destination:"syz"},
    {origin:"mhd",destination:"thr"},
  	{origin:"kih",destination:"thr"},
	{origin:"ifn",destination:"thr"},
  	{origin:"syz",destination:"thr"}
  ]


  def perform(date)
  	@@origin_destination.each do |x|
      background_search = SearchController.new()
      background_search.backgound_search_proccess(x[:origin],x[:destination],date)
    end
  end
end