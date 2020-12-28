module SupplierHelper
  def create_supplier(
    supplier:,
    origin: 'thr',
    destination: 'mhd',
    date: '2021-01-01'
  )
    route = Route.find_or_create_by(origin: origin, destination: destination)
    search_history = SearchHistory.create(supplier_name: supplier.name, route: route)
    supplier.new(
      origin: origin,
      destination: destination,
      route: route,
      date: date,
      search_history: search_history,
      supplier_name: supplier.name
    )
  end
end
