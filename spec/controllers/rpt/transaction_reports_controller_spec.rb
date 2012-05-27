require "spec_helper"
require "controllers/rpt/shared_examples_for_reports"

describe Rpt::TransactionReportsController do
  let(:staff) { FactoryGirl.create :staff }

  it_behaves_like "a report", %w[html csv]

  it "assigns certain variables" do
    sign_in staff
    get :show, format: 'html', year: staff.year
    expected_assigns = %w[transactions sales comps refunds
      sales_sum comps_sum refunds_sum total_sum]
    expected_assigns.each{ |v|
      assigns(v.to_sym).should_not be_nil
    }
  end


  it "is limited to the current year" do
    sign_in staff

    # create transactions in different years
    1.upto(3) { FactoryGirl.create(:tr_sale, year: Time.now.year + 1) }
    this_year_sales = 1.upto(3).map{ FactoryGirl.create(:tr_sale) }
    expected_sales_count = this_year_sales.count
    expected_sum = this_year_sales.map(&:amount).reduce(:+)

    # expect to only see this year's sales on report
    get :show, :year => Time.now.year
    assigns(:sales).should have(expected_sales_count).sales
    assigns(:sales_sum).should be_within(0.001).of(expected_sum)
  end

end
