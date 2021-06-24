# frozen_string_literal: true

class UserController < ApplicationController
  before_action :authenticate_user

  def index
    @user = current_user
  end
end
