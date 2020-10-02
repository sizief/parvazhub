# frozen_string_literal: true

class MostSearchRoute < ApplicationRecord
  validates_uniqueness_of :route_id
  belongs_to :route

  def get(limit)
    MostSearchRoute.order(count: :desc).limit(limit)
  end

  def perform
    max_number_of_routes = 30
    user_search_histories = UserSearchHistory.where('created_at >?', '2019-09-11')
    routes = user_search_histories.group(:route_id).order('count_id desc').count('id')

    routes.each_with_index do |route, index|
      break if index > max_number_of_routes.to_f

      begin
        unless Route.find(route.first).flights.empty?
          most_search_route = MostSearchRoute.find_or_create_by(route_id: route.first)
          most_search_route.count = route.second
          most_search_route.save
        end
      rescue StandardError
      end
    end
  end
end
