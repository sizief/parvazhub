class Telegram::Method 
  include SearchHelper
  include SearchResultHelper
  include ActionView::Helpers::NumberHelper

  @@number_of_result = 45
  if Rails.env.production?
    @@token = "bot360102838:AAHhtt5II-agroRJDLS-PuX-NcJ4G0kh0eg"
  else
    #test token
    @@token = "bot442162833:AAHubbvrXvdEfL8gXrVYJbwkh2DbjjyN5VU"
  end

  def get_updates
    last_update_id = Telegram::UpdateId.last.nil? ? 457549612 : Telegram::UpdateId.last[:update_id]
    get_update_url = "https://api.telegram.org/#{@@token}/getupdates?offset=#{last_update_id.to_i+1}"
    response = RestClient::Request.execute(method: :get, url: "#{URI.parse(get_update_url)}")
    return response.body
    #response = File.read("test/fixtures/files/telegram-updates.log") 
    #return response
  end

  def register_search_query(user, chat_id)
     begin
      Telegram::SearchQuery.create(telegram_user_id: user.telegram_id, chat_id: chat_id)
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
    answer="مبدا سفر کجاست؟"    
    keyboard = get_city_list()
    return {text: answer, chat_id: chat.chat_id, keyboard: keyboard, number_of_word_in_line: 3}  
  end

  def answer_step_1(chat,text,answer_valid)
    if answer_valid
      chat.origin = text
      chat.save
    end
    answer=" شهر مقصد را انتخاب کن"
    keyboard= get_city_list(chat.origin)
    return {text: answer, chat_id: chat.chat_id, keyboard: keyboard, number_of_word_in_line: 3}      
  end

  def answer_step_2(chat,text,answer_valid)
    if answer_valid
      chat.destination = text      
      chat.save
    end
    answer=" تاریخ سفرت را انتخاب کن"
    keyboard= get_dates
    return {text: answer, chat_id: chat.chat_id, keyboard: keyboard, number_of_word_in_line: 1}    
  end

  def answer_step_3(chat,text,answer_valid)
    if answer_valid
      chat.date = text
      chat.save
    end
    answer="لطفا چند لحظه صبر کن. در حال جستجوی سایت‌های فروش پرواز هستم."
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
    if ["/start","/reset","/Reset","/Start","جستجوی مجدد"].include? text
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
        send_search_result(chat)
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
    origin_code = City.get_city_code_based_on_name chat.origin
    #origin_name = City.list[origin_code.to_sym][:en]    
    origin_name = City.find_by(city_code: origin_code).english_name 
    
    destination_code = City.get_city_code_based_on_name chat.destination
    #destination_name = City.list[destination_code.to_sym][:en]    
    destination_name = City.find_by(city_code: destination_code).english_name 
    date = format_date chat.date

    text = "<b>پرواز شماره #{flight.flight_number} از #{chat.origin} به #{chat.destination} #{hour_to_human(flight.departure_time.to_datetime.strftime("%H:%M"))}  </b>"
    text += "<a href=\"https://parvazhub.com/flights/#{origin_name}-#{destination_name}/#{date}\" > | پروازهاب</a>\n\n" 
    flight_prices = SearchResultController.new.get_flight_price(Flight.find(flight_id),"telegram","telegram")
    if flight_prices.empty?
      text += "به نظر می‌رسد این پرواز پر شده. لطفا پرواز دیگری انتخاب کن"
    else
      flight_prices.each do |flight_price|
        redirect_link = "https://parvazhub.com/redirect/#{origin_name}-#{destination_name}/#{date}/#{flight_id}/#{flight_price[:id]}/telegram"
        text += "🚀 <a href=\"#{redirect_link}\">لینک خرید از سایت #{flight_price[:supplier_persian_name]} به قیمت #{number_with_delimiter(flight_price[:price])} تومان </a>  \n\n" 
      end
      text += "\n\n 📣جستجوی مسیر یا تاریخ جدید: \n/start"      
    end
    send({text:text,chat_id:chat.chat_id})
    
  end

  def send_search_result(chat)
    text = "<b> 📣 پروازهای #{chat.origin} به #{chat.destination} #{chat.date}</b> \n"
    origin_code = City.get_city_code_based_on_name chat.origin
    destination_code = City.get_city_code_based_on_name chat.destination
    date = format_date chat.date
    
    route = Route.find_by(origin:"#{origin_code}",destination:"#{destination_code}")
    flights = SearchResultController.new.get_flight_results({route: route,
                                                     date: date,
                                                     channel: "telegram",
                                                     user_agent_request: "telegram",
                                                     user_id: chat.telegram_user_id})
    
    if flights.empty?
      text += "برای این مسیر در این تاریخ متاسفانه پروازی پیدا نکردم. از صفحه کلید پایین صفحه می‌تونی روزهای دیگر را درخواست کنی و یا مسیر دیگری را جستجو کنی: /start"
    else 
      text += "📣 به ترتیب از ارزان‌ترین به گران‌ترین \n\n"      
      flights.each_with_index do |flight,index|
        next if index > @@number_of_result
        text += "#{flight[:airline_persian_name]} | #{hour_to_human(flight[:departure_time].to_datetime.strftime("%H:%M"))} | <b>#{number_with_delimiter(flight[:best_price])} تومان</b>
        👉 /flight#{flight[:id]} \n\n"
      end
      text += "\n\n 📣 جستجوی مسیر یا تاریخ جدید:\n /start"
      
    end
    send({text:text,chat_id:chat.chat_id,chat:chat})
    
  end

  def send(answer)
    text = answer[:text]
    chat_id = answer[:chat_id]
    keyboard = answer[:keyboard]
    number_of_word_in_line = answer[:number_of_word_in_line]
    send_url = "https://api.telegram.org/#{@@token}/sendMessage"

    if keyboard.nil? 
      reply_markup = ""
    else
      reply_markup= {"keyboard":prepare_for_telegram(keyboard,number_of_word_in_line),"one_time_keyboard":true}
    end
    body = {"chat_id":chat_id,"text":"#{text}","reply_markup":reply_markup,"parse_mode":"HTML"}
    begin
      RestClient::Request.execute(method: :post, payload: body.to_json, headers: {:'Content-Type'=> "application/json"}, url: "#{URI.parse(send_url)}")
    rescue
      body = {"chat_id":chat_id,"text":"متاسفانه مشکلی پیش آمده. تا رفع مشکل تاریخ‌های دیگری را می‌توانید جستجو کنید. سعی می‌کنیم مشکل را زود برطرف کنیم","reply_markup":reply_markup,"parse_mode":"HTML"}      
      RestClient::Request.execute(method: :post, payload: body.to_json, headers: {:'Content-Type'=> "application/json"}, url: "#{URI.parse(send_url)}")      
      #inform_support
      send({text:"ERROR: #{answer[:chat].origin}, #{answer[:chat].destination},#{answer[:chat].date}",chat_id:55584068})

    end
  end

  def update_by_pull
    response = get_updates
    response = JSON.parse(response)

    response["result"].each do |message|
      update(message)      
    end  
    return true
  end

  def update_by_webhook(response)
    response = JSON.parse(response)
    if ((response["channel_post"]) or (response["edited_channel_post"]))
      return true
    end
    update(response)
    return true        
  end

  def update (response)
    telegram_id = response["message"]["from"]["id"]
    first_name = response["message"]["from"]["first_name"]
    last_name = response["message"]["from"]["last_name"]
    username= response["message"]["from"]["username"]

    chat_id= response["message"]["chat"]["id"]
    text = response["message"]["text"]
    update_id = response["update_id"]

    is_new_message = Telegram::UpdateId.create(update_id: update_id)
    if is_new_message.save
      user = create_or_find_user(telegram_id,first_name,last_name,username)
      register_search_query(user, chat_id)
      select_answer(text,chat_id)
    end
  end

  def format_date(flight_date)
    hash_dates = Hash.new
    persian_dates = get_dates 
    persian_dates.each_with_index do |date,offset|
      hash_dates[date.to_sym] = (Date.today+offset.to_f).to_s
    end
    return hash_dates[flight_date.to_sym]
  end

  def get_city_list(selected_city=nil)
    cities = Array.new
    #City.list.each do |city|
    #  cities.push(city.last[:fa]) unless city.last[:fa] == selected_city
    #end

    City.where("priority < 40").order(:priority).each do |city|
      cities.push(city.persian_name) unless city.persian_name == selected_city
    end

    return cities
  end

  def get_dates
    dates = Array.new
    for offset in 0..6 do
      date = (Date.today+offset.to_f).to_parsi.strftime "%A %d %B"
      dates.push(date)
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

  def prepare_for_telegram(keyboard,number_of_word_in_line)
    keyboard_lines = Array.new
    telegram_line_index = -1

    keyboard.each_with_index do |word,index|
      if ((index % number_of_word_in_line.to_f == 0) or (index == 0))
        telegram_line_index += 1 
        keyboard_lines[telegram_line_index] = Array.new
      end
      keyboard_lines[telegram_line_index].push(word)
    end
    keyboard_lines.push(["جستجوی مجدد"])
    return keyboard_lines  
  end

  private

  def create_or_find_user(telegram_id,first_name,last_name,username)
    user = UserController.new.create_or_find_user_by_telegram({telegram_id: telegram_id, 
                                                          channel: "telegram", 
                                                          user_agent_request: "telegram",
                                                          first_name: first_name,
                                                          last_name: last_name,
                                                          user_name: username})
  end

end