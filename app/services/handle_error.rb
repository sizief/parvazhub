# frozen_string_literal: true

class HandleError
  def self.call(error)
    raise error if Rails.env.development?

    Sentry.capture_message(error) if Rails.env.production?
  end
end
