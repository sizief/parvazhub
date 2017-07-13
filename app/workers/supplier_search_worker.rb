require 'sidekiq-scheduler'

class SupplierSearchWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 2, :backtrace => true, :queue => 'critical'
 
  def perform(supplier_name, supplier_class,origin,destination,route_id,date,who_started)
    Timeout.timeout((ENV["SUPPLIER_TIMEOUT"].to_f)) do
      x = SupplierSearch.new
      x.search_supplier(supplier_name,supplier_class,origin,destination,route_id,date,who_started)
    end
  end

end