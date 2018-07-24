class Supplier < ApplicationRecord
    validates :name, :uniqueness => true

end
