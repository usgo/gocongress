require "rails_helper"

RSpec.describe AttendeesController, :type => :controller do
  render_views
  let(:activities) { 1.upto(3).map{ create :activity } }

  context "as a visitor" do
    describe "#index" do
      render_views

      it "succeeds" do
        a = create :attendee
        allow_any_instance_of(Attendee::WhoIsComing).to receive(:find_attendees) { [a] }
        allow_any_instance_of(Year).to receive(:registration_phase) { :open }
        get :index, params: { year: Time.current.year }
        expect(response).to be_successful
        expect(assigns(:who_is_coming)).not_to be_nil
      end
    end

    describe "#list" do
      it "is forbidden" do
        get :list, params: { year: Time.current.year }
        expect(response).to be_forbidden
      end
    end

    describe "#vip" do
      it "lists registered pros" do
        a1 = create :attendee, rank: 109
        a2 = create :attendee, rank: 108
        # 7 dans are not pros!
        a3 = create :attendee, rank: 7

        get :vip, params: { year: Time.current.year }

        if Time.current.year == 2019
          expect(response.status).to eq(302)
        else
          expect(assigns(:attendees).count).to be(2)
        end
      end

      it "doesn't list cancelled pros" do
        a1 = create :attendee, rank: 109
        # Cancelled!
        a2 = create :attendee, rank: 108, cancelled: true
        # 7 dans are not pros!
        a3 = create :attendee, rank: 7

        get :vip, params: { year: Time.current.year }

        if Time.current.year == 2019
          expect(response.status).to eq(302)
        else
          expect(assigns(:attendees).count).to be(1)
        end
      end
  end

  end

  context "as a user" do
    let(:user) { create :user }
    before { sign_in user }

    describe "#list" do
      it "is forbidden" do
        get :list, params: { year: user.year }
        expect(response).to be_forbidden
      end
    end
  end

  context "as staff" do
    let(:staff) { create :staff }
    before { sign_in staff }

    describe "#list" do
      it "is successful" do
        get :list, params: { year: staff.year }
        expect(response).to be_successful
      end
    end
  end

  context "as an admin" do
    let(:admin) { create :admin }
    before { sign_in admin }

    describe "#list" do
      it "is successful" do
        get :list, params: { year: admin.year }
        expect(response).to be_successful
      end
    end

    describe "#print_summary" do
      it "shows individual registration sheet" do
        a = create :attendee
        get :print_summary, params: { id: a.id, year: a.year }
        expect(response).to be_success
        expect(assigns(:attendee)).to eq(a)
        expect(assigns(:attendee_attr_names)).not_to be_empty
      end
    end

    describe "#destroy" do
      it "raises ActionController::UrlGenerationError" do
        a = create :attendee
        expect {
          delete :destroy, params: { id: a.id, year: a.year }
        }.to raise_error(ActionController::UrlGenerationError)
      end
    end
  end
end
