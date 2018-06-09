require "rails_helper"

RSpec.describe CheckInController, :type => :controller do
  describe "CheckInController", aga_td_list_mock: true do
    context "as a user" do
      render_views

      let(:user) { create :user }
      before { sign_in user }

      it "is forbidden to users" do
        user = create :user
        sign_in user
        get :index, params: { year: user.year }
        expect(response.code.to_i).to eq(403)
      end
    end

    context "as a staff member" do
      render_views

      let(:staff) { create :staff }
      before { sign_in staff }

      it "is accessible" do
        get :index, params: { year: staff.year }
        expect(response).to be_success
      end

      it "can't view check in list of attendees from another year" do
        get :index, params: { year: staff.year - 1 }
        expect(response.code.to_i).to eq(403)
      end

      it "can view individual attendees" do
        u = create :user
        a = create :attendee, user_id: u.id
        get :show, params: { year: staff.year, id: a.id }
        expect(response).to be_success
      end

      it "can check in and out attendees" do
        u = create :user
        a = create :attendee, user_id: u.id

        patch :check_in_attendee, params: { year: staff.year, id: u.id, attendee_id: a.id, checked_in: true }
        a.reload
        expect(a.checked_in).to be(true)

        patch :check_in_attendee, params: { year: staff.year, id: u.id, attendee_id: a.id, checked_in: false }
        a.reload
        expect(a.checked_in).to be(false)
      end

    end

    context "as an admin" do
      render_views

      let(:admin) { create :admin }
      before { sign_in admin }

      it "is accessible" do
        get :index, params: { year: admin.year }
        expect(response).to be_success
      end

      it "can't view check in list of attendees from another year" do
        get :index, params: { year: admin.year - 1 }
        expect(response.code.to_i).to eq(403)
      end

    end
  end
end
