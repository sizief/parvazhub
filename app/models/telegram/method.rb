class Telegram::Method 
  @@token = "bot360102838:AAHhtt5II-agroRJDLS-PuX-NcJ4G0kh0eg"

  def get_updates
    last_update_id = Telegram::UpdateId.last.nil? ? 34279410 : Telegram::UpdateId.last[:update_id]
    get_update_url = "https://api.telegram.org/#{@@token}/getupdates?offset=#{last_update_id.to_i+1}"
    response = RestClient::Request.execute(method: :get, url: "#{URI.parse(get_update_url)}")
    return response.body
    #response = File.read("test/fixtures/files/telegram-updates.log") 
    #return response
  end

  def register_user(telegram_id,first_name,last_name,username)
    begin
      Telegram::User.create(telegram_id: telegram_id, first_name: first_name, last_name: last_name, username: username)
    rescue ActiveRecord::RecordNotUnique
    end
  end

  def register_search_query(telegram_id, chat_id)
     begin
      telegram_user = Telegram::User.find_by(telegram_id: telegram_id)
      Telegram::SearchQuery.create(telegram_user_id: telegram_user.id, chat_id: chat_id)
    rescue ActiveRecord::RecordNotUnique
    end
  end
  
  def select_answer(text,chat_id)
    chat = Telegram::SearchQuery.find_by(chat_id: chat_id)
    
    #Step 0
    if text =="/start"
      answer="از کجا قصد سفر داری؟"
      chat.origin = nil
      chat.destination = nil
      chat.date = nil
      chat.save
      return {text: answer, chat_id: chat.chat_id}
    end 
    
    #Step 1
    if (chat.origin.nil? and chat.destination.nil?)
      chat.origin = text
      chat.save
      answer="لطفا شهر مقصد سفر رو انتخاب کن"
      return {text: answer, chat_id: chat.chat_id}
    end  
    
    #Step 2
    if (!chat.origin.nil? and chat.destination.nil?)
      chat.destination = text      
      chat.save
      answer="لطفا تاریخ سفرت رو انتخاب کن"
      return {text: answer, chat_id: chat.chat_id}
    end
    
    #Step 3
    if (!chat.origin.nil? and !chat.destination.nil?)
      chat.date = text
      chat.save
      answer="لطفا چند لحظه صبر کنید در حال جستجو"
      return {text: answer, chat_id: chat.chat_id}
    end
    
    
  end

  def send(text,chat_id)
    send_url = "https://api.telegram.org/#{@@token}/sendMessage"
    body = {"chat_id":chat_id,"text":"#{text}"}
    response = RestClient::Request.execute(method: :post, payload: body.to_json, headers: {:'Content-Type'=> "application/json"}, url: "#{URI.parse(send_url)}")
 #   ,"reply_markup": 
#{"keyboard":[["مشهد", "تهران"]]}
  end

  def update
    response = get_updates
    response = JSON.parse(response)

    response["result"].each do |message|
      telegram_id = message["message"]["from"]["id"]
      first_name = message["message"]["from"]["first_name"]
      last_name = message["message"]["from"]["last_name"]
      username= message["message"]["from"]["username"]

      chat_id= message["message"]["chat"]["id"]
      text = message["message"]["text"]
      update_id = message["update_id"]

      Telegram::UpdateId.create(update_id: update_id)
      register_user(telegram_id,first_name,last_name,username)
      register_search_query(telegram_id, chat_id)

      answer = select_answer(text,chat_id)
      send(answer[:text],answer[:chat_id])
    end   
  end

  

end