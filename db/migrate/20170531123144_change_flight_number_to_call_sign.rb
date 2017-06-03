class ChangeFlightNumberToCallSign < ActiveRecord::Migration[5.0]
  def change
  	rename_column :flight_details, :flight_number, :call_sign
  end
end
