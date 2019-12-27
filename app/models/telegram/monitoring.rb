# frozen_string_literal: true

class Telegram::Monitoring
  @@token = ENV['TELEGRAM']

  def send(answer)
    text = answer[:text]
    chat_id = 55_584_068
    send_url = "https://api.telegram.org/#{@@token}/sendMessage"

    body = { "chat_id": chat_id, "text": text.to_s, "parse_mode": 'HTML' }
    begin
      RestClient::Request.execute(method: :post, payload: body.to_json, headers: { 'Content-Type': 'application/json' }, url: URI.parse(send_url).to_s)
    rescue StandardError
      send(text: 'ERROR', chat_id: 55_584_068)
    end
    end
end
