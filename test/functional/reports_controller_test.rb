require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create :user
    @staff = FactoryGirl.create :staff
    @admin = FactoryGirl.create :admin
  end

  test "admin can get all reports" do
    sign_in @admin
    
    # Because there is no data in the test db, it is feasible to run all
    # of the reports, just to make sure they are successful
    
    # The following reports take no paramters, and only respond to html
    %w[index invoices emails activities outstanding_balances
        tournaments user_invoices].each do |r|
      get r, :year => Time.now.year
      assert_response :success
    end
    
    # These reports also respond to csv
    %w[attendees transactions].each do |r|
      %w[html csv].each do |f|
        get r, :format => f, :year => Time.now.year
      end
    end
    
    # Finally, these two reports take a min and max parameter
    %w[atn_badges_all atn_reg_sheets].each do |r|
      get r, :year => Time.now.year, :min => 'a', :max => 'z'
      assert_response :success
    end
  end

  test "staff can get attendees report" do
    sign_in @staff
    get :attendees, :format => 'csv', :year => Time.now.year
    assert_response :success
  end

  test "user cannot get attendees report" do
    sign_in @user
    get :attendees, :format => 'csv', :year => Time.now.year
    assert_response 403
  end
  
  test "transaction report limited to current year" do
    sign_in @admin
    
    # create transactions in different years
    1.upto(3) { FactoryGirl.create(:tr_sale, year: Time.now.year + 1) }
    this_year_sales = []
    1.upto(3) { this_year_sales << FactoryGirl.create(:tr_sale) }
    expected_sum = this_year_sales.map(&:amount).reduce(:+)
    
    # expect to only see this year's sales on report
    get :transactions, :year => Time.now.year
    assert_response :success
    assert_not_nil assigns["sales"]
    assert_not_nil assigns["sales_sum"]
    assert_equal this_year_sales.count, assigns["sales"].count
    assert_in_delta expected_sum.to_f, assigns["sales_sum"].to_f
  end

  test "outstanding balances" do
    sign_in @admin
    FactoryGirl.create :tr_sale, amount: 10000, user_id: @user.id
    get :outstanding_balances, :year => Time.now.year
    assert_not_nil assigns["users"]
    assert !assigns["users"].map(&:id).include?(@user.id)
  end

end
