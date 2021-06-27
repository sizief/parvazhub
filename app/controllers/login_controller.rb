# frozen_string_literal: true

class LoginController < ApplicationController
  def new
    redirect_to profile_path if current_user
  end

  def create
    if user = authenticate_with_google
      cookies.signed.permanent[:user_id] = user.id
      redirect_to home_path
    else
      redirect_to home_path, alert: 'authentication_failed'
    end
  end

  def destroy
    cookies.signed[:user_id] = nil
    redirect_to root_path
  end

  private

  def authenticate_with_google
    id_token = flash[:google_sign_in]['id_token']
    return flash[:google_sign_in][:error] unless id_token

    google_identity = GoogleSignIn::Identity.new(id_token)
    user = User.find_by google_user_id: google_identity.user_id
    return user if user

    create_user(google_identity)
  end

  def create_user(google_identity)
    User.create(
      email: google_identity.email_address,
      avatar_url: google_identity.avatar_url,
      first_name: google_identity.given_name,
      last_name: google_identity.family_name,
      locale: google_identity.locale,
      google_user_id: google_identity.user_id
    )
  end
end
