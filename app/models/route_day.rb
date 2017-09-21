class RouteDay < ApplicationRecord
#TODO
 #calculate flight days
 #
  def calculate
    City.list.each do |origin|
        City.list.each do |destination|
            unless destination == origin
                inspect_days(origin[0].to_s,destination[0].to_s)
            end
        end
    end
  end
 
  def inspect_days
  end
end
