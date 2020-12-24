# frozen_string_literal: true

class SearchHistory < ApplicationRecord
  belongs_to :route

  def append(status)
    update(status: "#{self.status} | #{Time.now.strftime('%M:%S')}:#{status}")
  end

  def set_success
    update(successful: true)
  end
end
