require "spec_helper"
require "controllers/rpt/shared_examples_for_reports"

describe Rpt::OutstandingBalanceReportsController do
  render_views

  it_behaves_like "a report", %w[html]

  describe "#show" do
    it "shows users with non-zero balances" do
      sign_in create :admin

      # One user paid too little
      a1 = create :attendee
      a1.plans << create(:plan)
      paid_too_little = a1.user

      # One user paid too much
      a2 = create :attendee
      paid_too_much = a2.user
      paid_too_much.transactions << create(:tr_sale)

      # The other paid juuuuuust right
      a3 = create :attendee
      paid_exactly = a3.user

      get :show, :year => Time.now.year
      assigns(:users).map(&:id).should =~ [paid_too_little.id, paid_too_much.id]
    end
  end

end
