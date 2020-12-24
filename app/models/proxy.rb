# frozen_string_literal: true

class Proxy < ApplicationRecord
  validates :ip, uniqueness: {
    scope: :port,
    message: 'already saved'
  }
  scope :enabled, -> { where(enable: true) }
  serialize :metadata, Hash
  before_create :add_metadata

  GAP = 5

  def self.fetch_path(supplier)
    proxy = Proxy.new.upread(supplier)
    return nil if proxy.nil?

    "https://#{proxy.ip}:#{proxy.port}"
  end

  # Each proxy should be used once in GAP second for each supplier
  # For example we can not use any proxy twice in under GAP seconds
  # when connecting to Ghasedak. So here we put a lock on select, we
  # find the random one which its last use is under GAP seconds.
  # Name is the combination of update + read :D 
  # The metadata property is updated every time this method is called.
  def upread(supplier)
    Proxy.transaction do
      proxies = Proxy.lock.enabled
      return nil if proxies.empty?

      proxies.shuffle.each do |proxy|
        next if proxy.metadata[slug_for(supplier)] + GAP.seconds > Time.now

        proxy.metadata[slug_for(supplier)] = Time.now
        proxy.save
        return proxy
      end

      # all proxies are used in last GAP seconds ago for this supplier
      # so return nothing
      nil
    end
  end

  private

  # Metadata is a hash that contains
  # key: name of each supplier
  # value: the last time this supplier uses that proxy
  def add_metadata
    self.metadata = Supplier.all.each_with_object({}) do |sp, hsh|
      hsh[sp.name] = Time.now
    end
  end

  def slug_for(supplier)
    supplier.name
  end
end
