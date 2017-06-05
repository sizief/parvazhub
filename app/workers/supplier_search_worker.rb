require 'sidekiq-scheduler'

class SupplierSearchWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true
 
  def perform(supplier_name, supplier_class,origin,destination,route_id,date)
     x = SupplierSearch.new
     x.search_supplier(supplier_name,supplier_class,origin,destination,route_id,date)
  end

end