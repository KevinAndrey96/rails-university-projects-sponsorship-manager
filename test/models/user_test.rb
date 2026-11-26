require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires a well formed, unique email address" do
    assert_not User.new(email_address: "not-an-email", password: "long-enough-secret").valid?
    assert_not User.new(email_address: "ONE@example.com", password: "long-enough-secret").valid?
    assert User.new(email_address: "new@example.com", password: "long-enough-secret").valid?
  end

  test "requires passwords of at least ten characters" do
    user = User.new(email_address: "new@example.com", password: "short")
    assert_not user.valid?
    assert user.errors.added?(:password, :too_short, count: User::MINIMUM_PASSWORD_LENGTH)
  end
end
