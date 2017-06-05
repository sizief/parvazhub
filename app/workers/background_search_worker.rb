require 'sidekiq-scheduler'

class BackgroundSearchWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1, :backtrace => true
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
      background_search = SupplierSearch.new()
      background_search.background_search(x[:origin],x[:destination],date)
      break if Rails.env.test? 
    end
  end

end