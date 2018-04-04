require 'sidekiq-scheduler'

class AmplitudeWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true, :backtrace => true, :queue => 'low'
 
  def perform(user_id, event)
    Timeout.timeout(60) do
      send user_id, event
    end
  end

  def send user_id, event
    url = "https://api.amplitude.com/httpapi?api_key=3d021d450c1857b8413ba328cd6a0078&event=[{\"user_id\":\"#{user_id}\", \"event_type\":\"#{event}\"}]"
    RestClient::Request.execute(method: :get, url: "#{URI.parse(url)}")
  end

end