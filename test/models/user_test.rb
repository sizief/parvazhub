require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "create guest user" do
    args = {telegram_id: "1234", channel: "telegram"}
    assert_difference 'User.count', 1 do
      User.new.create_guest_user args
    end
  end
end
