class Country < ApplicationRecord
    validates :country_code, :uniqueness => true
    
end
