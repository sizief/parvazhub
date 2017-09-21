class RouteDay < ApplicationRecord
  validates :route_id, :uniqueness => { :scope => :day_code,
  :message => "already exist" }
  belongs_to :route

  def calculate_all
    City.list.each do |origin|
      City.list.each do |destination|
        unless destination == origin
          route = Route.find_by(origin: origin[0], destination: destination[0])
          days_available = inspect_days(route.id)
          import(days_available,route.id)
        end
      end
    end
  end
 
  def inspect_days(route_id)
    days =Array.new
    flight_details = FlightDetail.where(route_id: route_id)
    unless flight_details.nil?
      flight_details.each do |flight_detail|
        day_index = flight_detail.departure_time.to_date.wday
        unless days.include? day_index
          days.push day_index
        end
      end
    end
    return days
  end

  def import(days_available,route_id)
    days_available.each do |day|
       RouteDay.create(route_id: route_id, day_code: day)
    end
  end

  def self.week_days(origin,destination)
    days = Array.new
    route = Route.find_by(origin: origin, destination: destination)
    route_days = RouteDay.where(route: route.id)
    route_days.each do |route_day|
      days.push route_day.day_code
    end
    return days
  end


end
