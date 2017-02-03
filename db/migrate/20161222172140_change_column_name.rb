class ChangeColumnName < ActiveRecord::Migration[5.0]
  def change
  	    rename_column :flights, :deaprture_time, :departure_time
  	    rename_column :flights, :airline_name, :airline_code
  	    #change_column :flights, :departure_time, :string
  end
end
