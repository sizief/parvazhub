class Review < ApplicationRecord
  belongs_to :user
  enum category: [:general, :airline, :supplier]
end
