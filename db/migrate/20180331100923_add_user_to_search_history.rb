# frozen_string_literal: true

class AddUserToSearchHistory < ActiveRecord::Migration[5.0]
  def change
    add_reference :user_search_histories, :user, index: true, foreign_key: true
  end
end
