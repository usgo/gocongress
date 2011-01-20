require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory.build(:user).valid?
  end

  test "a user with N attendee owes N * 75 dollars" do
    u = Factory(:user)
    num_extra_attendees = 1 + rand(3)
    1.upto(num_extra_attendees) { |a|
      u.attendees << Factory(:attendee, :user_id => u.id)
      }
    assert_equal num_extra_attendees + 1, u.attendees.size
    assert_equal (num_extra_attendees + 1) * 75, u.get_invoice_total
  end

  test "amount paid is sum of transactions" do
    u = Factory(:user)
    num_transactions = 10
    expected_sum = 0
    1.upto(num_transactions) { |n|
      t = Factory(:transaction, :user_id => u.id)
      expected_sum += t.amount
      u.transactions << t
      }
    assert_equal num_transactions, u.transactions.where(:trantype => 'S').length
    assert_equal expected_sum, u.amount_paid
  end

  test "balance" do
    u = Factory(:user)
    1.upto(1+rand(3)) { |a| u.attendees << Factory(:attendee, :user_id => u.id) }
    1.upto(1+rand(10)) { |n| u.transactions << Factory(:transaction, :user_id => u.id) }
    assert_equal u.get_invoice_total - u.amount_paid, u.balance
  end

  test "sum of invoice equals invoice total" do
    u = Factory(:user)
    1.upto(1+rand(3)) { |a| u.attendees << Factory(:attendee, :user_id => u.id) }
    expected_sum = 0
    u.get_invoice_items.each { |ii| expected_sum += ii['item_price'] }
    assert_equal expected_sum, u.get_invoice_total
  end

end
