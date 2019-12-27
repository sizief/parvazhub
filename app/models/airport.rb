# frozen_string_literal: true

class Airport < ApplicationRecord
  validates :iata_code, uniqueness: true
end
