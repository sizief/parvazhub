# frozen_string_literal: true

# Each user search has a unique SearchFlightId (call it token)
# We store each flight ids as a array in string, in separate row
# for each supplier. So for a usuall search for THR to MHD with 3
# active suppliers, we have 4 rows in SearchFlightId. First one is
# empty and has a token only, the other three can have empty
# flightIds or an array of flight Ids.
#
class SearchFlightId < ApplicationRecord
  def self.ids(token)
    SearchFlightId
      .select(:flight_ids)
      .where(token: token)
      .map do |sf|
        next nil if sf.flight_ids.nil?

        sf.flight_ids.tr('[]', '').split(',').map(&:to_i)
      end.flatten.compact.uniq
  end
end
