# frozen_string_literal: true

class HandleError
  def self.call(error)
    raise error if Rails.env.development?
  end
end
