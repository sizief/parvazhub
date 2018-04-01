require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new
  end
  
  test "create guest user" do
    args = {telegram_id: "1234", channel: "telegram"}
    assert_difference 'User.count', 1 do
      @user.send(:create_guest_user, args)
    end
  end

  test "find user if id is exists" do
    first_user = @user.send(:create_guest_user, {channel: "telegram"})
    args = {user_id: first_user.id}
    second_user = @user.create_or_find_user_by_id args
    assert second_user.id == first_user.id
  end

  test "find user if telegram is exists" do
    first_user = @user.send(:create_guest_user, {telegram_id: "123456"})
    args = {telegram_id: first_user.telegram_id}
    second_user = @user.create_or_find_user_by_telegram args
    assert second_user.telegram_id == first_user.telegram_id
  end
end
