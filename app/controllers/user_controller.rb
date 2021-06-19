# frozen_string_literal: true

class UserController < ApplicationController
  def create_or_find_user_by_id(args)
    user = if is_bot(args[:user_agent_request])
             get_bot_user
           else
             User.new.create_or_find_user_by_id args
           end
    user
  end

  def get_app_user
    user = User.find_by(email: 'app@parvazhub.com')
  end

  def get_job_user
    user = User.find_by(email: 'app@parvazhub.com')
  end

  private

  def get_bot_user
    user = User.find_by(email: 'bot@parvazhub.com')
  end
end
