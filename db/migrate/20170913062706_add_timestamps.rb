class AddTimestamps < ActiveRecord::Migration[5.0]
  def change
    add_timestamps(:user_flight_price_histories)    
  end
end
