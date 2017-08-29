require 'sidekiq-scheduler'

class BackgroundSearchWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1, :backtrace => true
  @@origin_destination = [
  	{origin:"thr",destination:"mhd"},
  	{origin:"thr",destination:"kih"},
  	{origin:"thr",destination:"ifn"},
  	{origin:"thr",destination:"syz"},
    {origin:"thr",destination:"tbz"},
    {origin:"thr",destination:"abd"},
    {origin:"thr",destination:"awz"},
    {origin:"mhd",destination:"thr"},
  	{origin:"kih",destination:"thr"},
	  {origin:"ifn",destination:"thr"},
  	{origin:"syz",destination:"thr"},
    {origin:"tbz",destination:"thr"},
    {origin:"abd",destination:"thr"},
    {origin:"awz",destination:"thr"}
  ]

  def perform(date_offset)
    date = (Date.today+date_offset.to_f).to_s
  	@@origin_destination.each do |x|
      background_search = SupplierSearch.new()
      background_search.background_search(x[:origin],x[:destination],date)
      #sleep 8
      break if Rails.env.test? 
    end
  end

end