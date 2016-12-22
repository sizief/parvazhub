class Route < ApplicationRecord
	validates :origin, presence: true
	validates :destination, presence: true
	validates :origin, :uniqueness => { :scope => :destination,
    :message => "already saved" }
end
