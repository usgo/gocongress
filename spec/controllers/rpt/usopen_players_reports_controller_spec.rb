require "rails_helper"
require "controllers/rpt/shared_examples_for_reports"

RSpec.describe Rpt::UsopenPlayersReportsController, aga_td_list_mock: true, :type => :controller do
  it_behaves_like "a report", %w[html xml]

  context "as an admin" do
    render_views

    let(:admin) { create :admin }
    before { sign_in admin }

    describe "#show" do
      it "succeeds" do
        get :show, params: { year: Date.current.year }
        expect(response).to be_success
      end

      it "only shows who are signed up to play in the open and haven't cancelled" do
        sign_in create :admin

        # One user won't play in the open
        non_player = create :attendee

        # One user will play in the open
        player = create :attendee, will_play_in_us_open: true

        # One user is cancelled
        cancelled_player = create :attendee, cancelled: true, will_play_in_us_open: true

        get :show, params: { year: Time.now.year }
        expect(assigns(:players)).to match_array([player])
      end

      it "gets AGA info from usgo.org" do
        get :show, params: { year: Time.now.year }
        expect(assigns.keys).to include('aga_member_info')
      end

    end
  end
end
