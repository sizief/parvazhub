# frozen_string_literal: true

class Country < ApplicationRecord
  validates :country_code, uniqueness: true
end
