# frozen_string_literal: true

class En::SearchResultController < SearchResultController
  layout 'en/layouts/application'

  private

  def date_to_human(date)
    date = date.to_date
    if date == Date.today
      'Today'
    elsif date == (Date.today + 1)
      'Tomorrow'
    else
      date.to_date.strftime ' %-d %B'
    end
  end
end
