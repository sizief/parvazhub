# frozen_string_literal: true

class User < ApplicationRecord
  validates :email, uniqueness: true
  validates :google_user_id, uniqueness: true

  has_many :user_search_histories, dependent: :destroy
  has_many :user_flight_price_histories, dependent: :destroy
  has_many :reviews
  has_many :redirects, dependent: :destroy

  ANONYMOUS_EMAIL = 'anonymous@parvazhub.com'
  ADMIN = 'admin'
  BASIC = 'basic'

  def self.anonymous_user
    User.where(email: ANONYMOUS_EMAIL).first_or_create
  end

  def anonymous?
    email == ANONYMOUS_EMAIL
  end

  def admin?
    role == 'admin'
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
