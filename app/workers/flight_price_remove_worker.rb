require 'sidekiq-scheduler'

class FlightPriceRemoveWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1, :backtrace => true
  @@conditions = [
  	{date:Date.today.to_s,outdate_minutes:41},
    {date:(Date.today+1).to_s,outdate_minutes:121},
    {date:(Date.today+2).to_s,outdate_minutes:241},
    {date:(Date.today+3).to_s,outdate_minutes:721},
    {date:(Date.today+4).to_s,outdate_minutes:721},
    {date:(Date.today+5).to_s,outdate_minutes:721},
    {date:(Date.today+6).to_s,outdate_minutes:721},
    {date:(Date.today+7).to_s,outdate_minutes:721}
 ]

  def perform
    @@conditions.each do |condition|
     remove_flight_prices(condition[:date],condition[:outdate_minutes])
    end
  end

  def remove_flight_prices(date,outdate_minutes)
    outdate_flight_prices = FlightPrice.where(flight_date: date).where('created_at < ?', outdate_minutes.to_f.minutes.ago)
    unless outdate_flight_prices.empty?
      outdate_flight_prices.delete_all
    end
  end

end