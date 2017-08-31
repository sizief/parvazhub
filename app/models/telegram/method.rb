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
  
  def answer_step_0(chat,text)
    answer="از کجا قصد سفر داری؟"
    chat.origin = nil
    chat.destination = nil
    chat.date = nil
    chat.save
    keyboard = get_city_list
    return {text: answer, chat_id: chat.chat_id, keyboard: keyboard}  
  end

  def answer_step_1(chat,text)
    chat.origin = text
    chat.save
    answer="لطفا شهر مقصد سفر رو انتخاب کن"
    keyboard= get_city_list(chat.origin)
    return {text: answer, chat_id: chat.chat_id, keyboard: keyboard}      
  end

  def answer_step_2(chat,text)
    chat.destination = text      
    chat.save
    answer="لطفا تاریخ سفرت رو انتخاب کن"
    keyboard= get_dates
    return {text: answer, chat_id: chat.chat_id, keyboard: keyboard}    
  end

  def answer_step_3(chat,text)
    chat.date = text
    chat.save
    answer="لطفا چند لحظه صبر کنید در حال جستجو"
    return {text: answer, chat_id: chat.chat_id}    
  end
  
  
  def select_answer(text,chat_id)
    chat = Telegram::SearchQuery.find_by(chat_id: chat_id)
  
    #Step 0
    if text =="/start" or text =="جستجوی مجدد"
      return answer_step_0(chat,text)
    end 
    
    #Step 1
    if (chat.origin.nil? and chat.destination.nil?)
      if is_city_valid(text)
        #apologize(chat.id)
        return answer_step_1(chat,text)
      else
        return answer_step_0(chat,text)
      end
    end  
    
    #Step 2
    if (!chat.origin.nil? and chat.destination.nil?)
      return answer_step_2(chat,text)
    end
    
    #Step 3
    if (!chat.origin.nil? and !chat.destination.nil?)
      return answer_step_3(chat,text)
    end
  end

  def is_city_valid(city)
    cities = get_city_list
    cities.include? city
  end

  def apologize(chat_id)
    text = "متوجه نشدم. لطفا یکی از موارد  پایین را انتخاب کنید"
    send(text,chat_id)    
  end

  def get_city_list(selected_city=nil)
    cities = Array.new
    City.list.each do |city|
      cities.push(city.last[:fa]) unless city.last[:fa] == selected_city
    end
    return cities
  end

  def get_dates
    dates = Array.new
    for offset in 0..6 do
      dates.push((Date.today+offset.to_f).to_parsi.strftime "%A %d %B"  )
    end
    return dates
  end

  def send(text,chat_id,keyboard=nil)
    send_url = "https://api.telegram.org/#{@@token}/sendMessage"
    if keyboard.nil? 
      reply_markup = ""
    else
      reply_markup= {"keyboard":[keyboard,["جستجوی مجدد"]],"one_time_keyboard":true}
    end
    body = {"chat_id":chat_id,"text":"#{text}","reply_markup":reply_markup}
    response = RestClient::Request.execute(method: :post, payload: body.to_json, headers: {:'Content-Type'=> "application/json"}, url: "#{URI.parse(send_url)}")
  end

  def search(route,origin_name,origin_code,destination_name,destination_code,date)
    @flights = Flight.new.flight_list(route,date)

    date_in_human = date.to_date.to_parsi.strftime '%A %d %B'     
    @search_parameter ={origin_name: origin_name, origin_code: origin_code, destination_code: destination_code, destination_name: destination_name,date: date, date_in_human: date_in_human}
    @cities = City.list 

    render :index
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
      send(answer[:text],answer[:chat_id],answer[:keyboard])
    end   
  end

  

end