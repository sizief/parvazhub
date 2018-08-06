class Telegram::Monitoring 
    @@token = ENV["TELEGRAM"]

    def send(answer)
        text = answer[:text]
        chat_id = 55584068
        send_url = "https://api.telegram.org/#{@@token}/sendMessage"
    
        
        body = {"chat_id":chat_id,"text":"#{text}","parse_mode":"HTML"}
        begin
          RestClient::Request.execute(method: :post, payload: body.to_json, headers: {:'Content-Type'=> "application/json"}, url: "#{URI.parse(send_url)}")
        rescue
          send({text:"ERROR",chat_id:55584068})
    
        end
      end
end
    
    