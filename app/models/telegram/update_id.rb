class Telegram::UpdateId < ApplicationRecord
    self.table_name = "telegram_update_ids"
    validates :update_id, :uniqueness => true

end
