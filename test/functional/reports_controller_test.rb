require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create :user
    @staff = FactoryGirl.create :staff
    @admin = FactoryGirl.create :admin
  end

  test "admin can get all reports" do
    sign_in @admin

    # The following reports take no paramters, and only respond to html
    %w[index invoices emails activities outstanding_balances tournaments].each do |r|
      get r, :year => @admin.year
      assert_response :success
    end

    # These reports take a min and max parameter
    %w[atn_badges_all atn_reg_sheets user_invoices].each do |r|
      get r, :year => @admin.year, :min => 'a', :max => 'z'
      assert_response :success
    end
  end

end
