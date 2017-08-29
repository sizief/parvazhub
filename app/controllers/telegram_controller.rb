class TelegramController < ApplicationController

    def update
        x=Telegram::Method.new
        @errors = x.update
    end
end    