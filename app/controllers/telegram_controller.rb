class TelegramController < ApplicationController
    skip_before_action :verify_authenticity_token        
    
    def update
        x=Telegram::Method.new
        @errors = x.update_by_pull
    end

    def webhook
        response = request.body.read
        Telegram::Method.new.update_by_webhook(response)
    end
end    