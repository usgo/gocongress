require "rails_helper"
require "controllers/rpt/shared_examples_for_reports"

RSpec.describe Rpt::TransactionReportsController, :type => :controller do
  let(:staff) { create :staff }

  it_behaves_like "a report", %w[html csv]

  it "assigns certain variables" do
    sign_in staff
    get :show, format: 'html', params: { year: staff.year }
    expected_assigns = %w[transactions sales comps refunds
      sales_sum comps_sum refunds_sum net_income]
    expected_assigns.each{ |v|
      expect(assigns(v.to_sym)).not_to be_nil
    }
  end

  it "is limited to the current year" do
    sign_in staff

    # create transactions in different years
    1.upto(3) { create(:tr_sale, year: Time.now.year + 1) }
    this_year_sales = 1.upto(3).map{ create(:tr_sale) }
    expected_sales_count = this_year_sales.count
    expected_sum = this_year_sales.map(&:amount).reduce(:+)

    # expect to only see this year's sales on report
    get :show, params: { year: Time.now.year }
    expect(assigns(:sales).sales.size).to eq(expected_sales_count)
    expect(assigns(:sales_sum)).to be_within(0.001).of(expected_sum)
  end

  describe 'csv format' do
    it "has one line for each transaction, plus a header" do
      y = Time.current.year
      3.times { |i| create :tr_sale }
      create :tr_comp, comment: 'volunteer comp'
      create :tr_refund

      sign_in staff
      get :show, format: 'csv', params: { year: y }
      expect(response).to be_success
      ary = CSV.parse response.body
      expect(ary.size).to eq(6)
    end

    it "shows user_id" do
      t = create :tr_sale
      sign_in staff
      get :show, format: 'csv', params: { year: Time.current.year }
      expect(response).to be_success
      ary = CSV.parse response.body
      expect(ary[0]).to include 'user_id'
      expect(ary[1][ary[0].index 'user_id']).to eq(t.user_id.to_s)
    end
  end
end
