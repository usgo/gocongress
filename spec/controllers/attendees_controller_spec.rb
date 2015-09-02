require "spec_helper"

describe AttendeesController, :type => :controller do
  render_views
  let(:activities) { 1.upto(3).map{ create :activity } }

  context "as a visitor" do
    describe "#index" do
      render_views

      it "succeeds" do
        a = create :attendee
        allow_any_instance_of(Attendee::WhoIsComing).to receive(:find_attendees) { [a] }
        allow_any_instance_of(Year).to receive(:registration_phase) { :open }
        get :index, :year => Time.current.year
        expect(response).to be_successful
        expect(assigns(:who_is_coming)).not_to be_nil
      end
    end

    describe "#list" do
      it "is forbidden" do
        get :list, :year => Time.current.year
        expect(response).to be_forbidden
      end
    end
  end

  context "as a user" do
    let(:user) { create :user }
    before { sign_in user }

    describe "#list" do
      it "is forbidden" do
        get :list, :year => user.year
        expect(response).to be_forbidden
      end
    end
  end

  context "as staff" do
    let(:staff) { create :staff }
    before { sign_in staff }

    describe "#list" do
      it "is successful" do
        get :list, :year => staff.year
        expect(response).to be_successful
      end
    end
  end

  context "as an admin" do
    let(:admin) { create :admin }
    before { sign_in admin }

    describe "#list" do
      it "is successful" do
        get :list, :year => admin.year
        expect(response).to be_successful
      end
    end

    describe "#print_summary" do
      it "shows individual registration sheet" do
        a = create :attendee
        get :print_summary, :id => a.id, :year => a.year
        expect(response).to be_success
        expect(assigns(:attendee)).to eq(a)
        expect(assigns(:attendee_attr_names)).not_to be_empty
      end
    end

    describe "#destroy" do
      it "raises ActionController::UrlGenerationError" do
        a = create :attendee
        expect { delete :destroy, :id => a.id, :year => a.year
          }.to raise_error(ActionController::UrlGenerationError)
      end
    end
  end
end
