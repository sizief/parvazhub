class Telegram::Method < ApplicationRecord
  @@token = "bot360102838:AAHhtt5II-agroRJDLS-PuX-NcJ4G0kh0eg"

  def get_updates
    get_update_url = "https://api.telegram.org/#{@@token}/getupdates"
    response = RestClient::Request.execute(method: :get, url: "#{URI.parse(get_update_url)}")


  end
  
end
