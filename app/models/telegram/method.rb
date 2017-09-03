class Telegram::Method 
  include SearchHelper
  include SearchResultHelper
  include ActionView::Helpers::NumberHelper

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
  
  def answer_step_0(chat,text,answer_valid)
    if answer_valid
      chat.origin = nil
      chat.destination = nil
      chat.date = nil
      chat.save
    end
    answer="از کجا قصد سفر داری؟"    
    keyboard = get_city_list
    return {text: answer, chat_id: chat.chat_id, keyboard: keyboard}  
  end

  def answer_step_1(chat,text,answer_valid)
    if answer_valid
      chat.origin = text
      chat.save
    end
    answer=" شهر مقصد سفر رو انتخاب کن"
    keyboard= get_city_list(chat.origin)
    return {text: answer, chat_id: chat.chat_id, keyboard: keyboard}      
  end

  def answer_step_2(chat,text,answer_valid)
    if answer_valid
      chat.destination = text      
      chat.save
    end
    answer=" تاریخ سفرت رو انتخاب کن"
    keyboard= get_dates
    return {text: answer, chat_id: chat.chat_id, keyboard: keyboard}    
  end

  def answer_step_3(chat,text,answer_valid)
    if answer_valid
      chat.date = text
      chat.save
    end
    answer="لطفا چند لحظه صبر کنید در حال جستجو"
    return {text: answer, chat_id: chat.chat_id}    
  end

  def answer_step_4(chat,text,answer_valid)
    if answer_valid
      chat.flight_price = text
      chat.save
    end
  end
  
  
  def select_answer(text,chat_id)
    chat = Telegram::SearchQuery.find_by(chat_id: chat_id)
  
    #Step 0
    if text =="/start" or text =="جستجوی مجدد"
      send answer_step_0(chat,text,true)
         
    #Step 1
    elsif (chat.origin.nil? and chat.destination.nil?)
      if is_city_valid(text)
        send answer_step_1(chat,text,true)
      else
        send({text:"شهری که درخواست کردی در لیست شهرهای ما نیست. از لیست پایین یکی را انتخاب کن 👇",chat_id:chat.chat_id})        
        send answer_step_0(chat,text,true)
      end
      
    
    #Step 2
    elsif (!chat.origin.nil? and chat.destination.nil?)
      if is_city_valid(text)
        send answer_step_2(chat,text,true)
      else
        send({text:"شهری که درخواست کردی در لیست شهرهای ما نیست. از لیست پایین یکی را انتخاب کن 👇",chat_id:chat.chat_id})        
        send answer_step_1(chat,text,false)
      end
    
    
    #Step 3
    elsif (!chat.origin.nil? and !chat.destination.nil? and !(text.include? "/"))
      if is_date_valid(text)
        send answer_step_3(chat,text,true)
        send_search_result(chat.origin,chat.destination,chat.date,chat.chat_id)
      else
        send({text:"تاریخی که درخواست کردی برای من مفهوم نیست. از لیست پایین یکی را انتخاب کن 👇",chat_id:chat.chat_id})         
        send answer_step_2(chat,text,false)
      end
    

    #Step 4
    elsif(text.include? "/flight")
      answer_step_4(chat,text.tr("/flight",""),true)  
      send_suppliers(text.tr("/flight",""),chat)
    end
        
  end

  def send_suppliers(flight_id,chat)
    flight = Flight.find(flight_id)
    text = "<b>پرواز شماره #{flight.flight_number} از #{chat.origin} به #{chat.destination} #{hour_to_human(flight.departure_time.to_datetime.strftime("%H:%M"))}  </b>\n\n"
    flight_prices = FlightPrice.where(flight_id: flight_id).order(:price)
    flight_prices.each do |flight_price|
      text += "🚀 <a href=\"https://parvazhub.com/redirect/telegram/#{flight_price.id}\">لینک خرید از سایت #{supplier_to_human(flight_price.supplier)} به قیمت #{number_with_delimiter(flight_price.price)} تومان </a>  \n"
    end
    text += "\n"
    send({text:text,chat_id:chat.chat_id})
    
  end

  def format_date(flight_date)
    hash_dates = Hash.new
    persian_dates = get_dates 
    persian_dates.each_with_index do |date,offset|
      hash_dates[date.to_sym] = (Date.today+offset.to_f).to_s
    end
    return hash_dates[flight_date.to_sym]
  end

  def send_search_result(origin_name,destination_name,date,chat_id)
    text = "<b>پروازهای #{origin_name} به #{destination_name} #{date}</b> \n\n"
    origin_code = City.get_city_code_based_on_name origin_name
    destination_code = City.get_city_code_based_on_name destination_name
    date = format_date date
    
    route = Route.find_by(origin:"#{origin_code}",destination:"#{destination_code}")
    SearchResultController.new.search_suppliers(route,date,"telegram")
    flights = Flight.new.flight_list(route,date)
    
    flights.each do |flight|
      text += "#{airline_name_for(flight.airline_code)} | #{hour_to_human(flight.departure_time.to_datetime.strftime("%H:%M"))} | <b>#{number_with_delimiter(flight.best_price)} تومان</b>
       👉 /flight#{flight.id} \n\n"
    end
    send({text:text,chat_id:chat_id})
    
  end

  def send(answer)
    text = answer[:text]
    chat_id = answer[:chat_id]
    keyboard = answer[:keyboard]
    send_url = "https://api.telegram.org/#{@@token}/sendMessage"

    if keyboard.nil? 
      reply_markup = ""
    else
      reply_markup= {"keyboard":prepare_for_telegram(keyboard),"one_time_keyboard":true}
    end
    body = {"chat_id":chat_id,"text":"#{text}","reply_markup":reply_markup,"parse_mode":"HTML"}
    response = RestClient::Request.execute(method: :post, payload: body.to_json, headers: {:'Content-Type'=> "application/json"}, url: "#{URI.parse(send_url)}")
  end

  def update_by_pull
    response = get_updates
    response = JSON.parse(response)

    response.each do |message|
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

      select_answer(text,chat_id)
    end   
  end

  def update_by_webhook(response)
    response = JSON.parse(response)

      telegram_id = response["message"]["from"]["id"]
      first_name = response["message"]["from"]["first_name"]
      last_name = response["message"]["from"]["last_name"]
      username= response["message"]["from"]["username"]

      chat_id= response["message"]["chat"]["id"]
      text = response["message"]["text"]
      update_id = response["update_id"]

      Telegram::UpdateId.create(update_id: update_id)
      register_user(telegram_id,first_name,last_name,username)
      register_search_query(telegram_id, chat_id)

      select_answer(text,chat_id)
       
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

  def is_city_valid(city)
    cities = get_city_list
    cities.include? city
  end

  def is_date_valid(date)
    dates = get_dates
    dates.include? date
  end

  def prepare_for_telegram(keyboard)
    keyboard_lines = Array.new
    telegram_line_index = -1

    keyboard.each_with_index do |word,index|
      if ((index % 3 == 0) or (index == 0))
        telegram_line_index = telegram_line_index + 1 
        keyboard_lines[telegram_line_index] = Array.new
      end
      keyboard_lines[telegram_line_index].push(word)
    end
    keyboard_lines.push(["جستجوی مجدد"])
    return keyboard_lines  
  end

end