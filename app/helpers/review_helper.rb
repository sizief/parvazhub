# frozen_string_literal: true

module ReviewHelper
  def supplier_farsi_name_for(supplier_name)
    Supplier.new.get_persian_name supplier_name
  end
end
