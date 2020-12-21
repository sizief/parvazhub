# frozen_string_literal: true

class SearchHistory < ApplicationRecord
  belongs_to :route

  def append(status)
    update(status: "#{self.status} | #{status}")
  end

  def set_success
    update(successful: true)
  end
end
