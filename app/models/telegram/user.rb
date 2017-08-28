class Telegram::User < ApplicationRecord
    self.table_name = "telegram_users"
    belongs_to :telegram_user,
            :class_name => 'Telegram::User',
            :foreign_key => 'telegram_users_id'

  	
end
