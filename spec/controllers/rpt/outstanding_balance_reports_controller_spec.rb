require "spec_helper"
require "controllers/rpt/shared_examples_for_reports"

describe Rpt::OutstandingBalanceReportsController do
  it_behaves_like "a report", %w[html]

  describe "#show" do
    it "shows users with non-zero balances" do
      sign_in FactoryGirl.create :admin

      # One user paid too little
      a1 = FactoryGirl.create :attendee, is_primary: true
      a1.plans << FactoryGirl.create(:plan)
      paid_too_little = a1.user

      # One user paid too much
      a2 = FactoryGirl.create :attendee, is_primary: true
      paid_too_much = a2.user
      paid_too_much.transactions << FactoryGirl.create(:tr_sale)

      # The other paid juuuuuust right
      a3 = FactoryGirl.create :attendee, is_primary: true
      paid_exactly = a3.user

      get :show, :year => Time.now.year
      assigns(:users).map(&:id).should =~ [paid_too_little.id, paid_too_much.id]
    end
  end

end
