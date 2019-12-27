# frozen_string_literal: true

class AddJobAllowedColumnToSuppliers < ActiveRecord::Migration[5.0]
  def change
    add_column :suppliers, :job_search_allowed, :boolean
  end
end
