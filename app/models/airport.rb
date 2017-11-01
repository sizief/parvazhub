class Airport < ApplicationRecord
    validates :iata_code, :uniqueness => true
    
end
