# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def price_alert
    NotificationMailer.price_alert('3', '2017-06-20', 'sizief@gmail.com', 'sub ject')
  end
end
