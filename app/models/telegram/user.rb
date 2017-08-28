class Telegram::User < ActiveRecord
    set_table_name "telegram_users"
    belongs_to :telegram_user,
           :class_name => 'Telegram::User'

  	
end
