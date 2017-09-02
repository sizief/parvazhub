class TelegramController < ApplicationController
    skip_before_action :verify_authenticity_token        
    
    def update
        x=Telegram::Method.new
        @errors = x.update
    end

    def webhook
        response = request.body.read
        Telegram::Method.new.update(response)
    end
end    