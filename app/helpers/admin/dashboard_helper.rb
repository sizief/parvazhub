# frozen_string_literal: true

module Admin::DashboardHelper
  def tehran_time(date)
    date - ENV['IRAN_ADDITIONAL_TIMEZONE'].to_f.minutes
  end

  def user_search_history(date, channel = nil)
    if channel.nil?
      user_search = UserSearchHistory.where('created_at > ? and created_at < ?', tehran_time(date), tehran_time(date + 1))
    else
      user_search = UserSearchHistory.where('created_at > ? and created_at < ?', tehran_time(date), tehran_time(date + 1)).where(channel: channel)
    end
    user_search.count
  end

  def user_search_history_all(channel = nil)
    user_search = if channel.nil?
                    UserSearchHistory.count
                  else
                    UserSearchHistory.where(channel: channel).count
                  end
  end

  def user_flight_price_history(date, channel = nil)
    if channel.nil?
      user_flight_price = UserFlightPriceHistory.where('created_at > ? and created_at < ?', tehran_time(date), tehran_time(date + 1)).count
    else
      user_flight_price = UserFlightPriceHistory.where('created_at > ? and created_at < ?', tehran_time(date), tehran_time(date + 1)).where(channel: channel).count
    end
  end

  def user_flight_price_history_all(channel = nil)
    user_flight_price = if channel.nil?
                          UserFlightPriceHistory.count
                        else
                          UserFlightPriceHistory.where(channel: channel).count
                        end
  end

  def redirect(date, channel = nil)
    count = 0
    application = ApplicationController.new
    if channel.nil?
      redirects = Redirect.where('created_at > ? and created_at < ?', tehran_time(date), tehran_time(date + 1))
    else
      redirects = Redirect.where('created_at > ? and created_at < ?', tehran_time(date), tehran_time(date + 1)).where(channel: channel)
    end
    redirects.each do |redirect|
      count += 1 unless application.is_bot(redirect.user_agent)
    end
    count
  end

  def redirect_all(channel = nil)
    redirect = if channel.nil?
                 Redirect.all.count
               else
                 Redirect.where(channel: channel).count
               end
  end

  def notification(date)
    notification = Notification.where('created_at > ? and created_at < ?', tehran_time(date), tehran_time(date + 1))
    notification.count
  end

  def notification_all
    notification = Notification.all
    notification.count
  end

  def search_history(date)
    search_history = SearchHistory.where('created_at > ? and created_at < ?', tehran_time(date), tehran_time(date + 1))
    search_history.count
  end

  def search_history_all
    search_history = SearchHistory.all
    search_history.count
  end

  def user(date)
    User.where('created_at > ?', tehran_time(date)).count
  end

  def review(date)
    Review.where('created_at > ?', tehran_time(date)).count
  end
end
