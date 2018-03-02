require "rails_helper"
require "controllers/rpt/shared_examples_for_reports"

RSpec.describe Rpt::OutstandingBalanceReportsController, :type => :controller do
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

      get :show, params: { year: Time.now.year }
      expect(assigns(:users).map(&:id)).to match_array([paid_too_little.id, paid_too_much.id])
    end
  end
end
