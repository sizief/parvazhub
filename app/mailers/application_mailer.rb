# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'salam@parvazhub.com'
  layout 'mailer'
end
