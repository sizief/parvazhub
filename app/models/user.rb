class User < ApplicationRecord
  enum channel: [:website, :telegram, :app]
  enum role: [:admin, :user]
  after_initialize :set_default_role, :if => :new_record?

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :telegram_id, :uniqueness => true,  :allow_blank => true
  has_many :user_search_histories, dependent: :destroy
  has_many :user_flight_price_histories, dependent: :destroy
  has_many :telegram_search_queries, class_name: "Telegram::SearchQuery",  dependent: :destroy
  has_many :redirects

  def set_default_role
    self.role ||= :user
  end
 
  def create_or_find_user_by_id args
    user = User.find_by(id: args[:user_id])
    user = create_guest_user({channel: args[:channel]}) if user.nil?
    user
  end

  def create_or_find_user_by_telegram args
    user = User.find_by(telegram_id: args[:telegram_id])
    if user.nil?
      user = create_guest_user({channel: args[:channel], 
                                telegram_id: args[:telegram_id],
                                first_name: args[:first_name],
                                last_name: args[:last_name]}) 
    end
    user
  end

  private
  def create_guest_user args
    user = User.create(:email => "guest_#{Time.now.to_i}#{rand(100)}@parvazhub.com", 
                 :telegram_id => args[:telegram_id],
                 :channel => args[:channel], 
                 :password => password,
                 :first_name => args[:first_name],
                 :last_name => args[:last_name])
  end

  def password
    password = (0...8).map { (65 + rand(26)).chr }.join
  end

end
