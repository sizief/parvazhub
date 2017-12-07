require 'sidekiq-scheduler'

class BackgroundSearchWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 0, :backtrace => true
  @@origin_destination = [
  	{origin:"thr",destination:"mhd"},
  	{origin:"thr",destination:"kih"},
    {origin:"thr",destination:"ist"},
    {origin:"mhd",destination:"thr"},
  	{origin:"kih",destination:"thr"},
    {origin:"ist",destination:"thr"},
  ]

  def perform(date_offset)
    date = (Date.today+date_offset.to_f).to_s
    
  	@@origin_destination.each do |x|
      #background_search = SupplierSearch.new()
      #background_search.search(x[:origin],x[:destination],date,40,"bg")
      #sleep 8
      route = Route.find_by(origin: x[:origin], destination: x[:destination])
      timeout = route.international? ? ENV["TIMEOUT_INTERNATIONAL"].to_i : ENV["TIMEOUT_DOMESTIC"].to_i

      SupplierSearch.new(origin: x[:origin],
                          destination: x[:destination],
                          date: date,
                          timeout: timeout,
                          who_started: "bg").search
      break if Rails.env.test? 
    end
  end

end