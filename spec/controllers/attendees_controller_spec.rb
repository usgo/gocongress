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
  end


  context "as an admin" do
    let(:admin) { create :admin }
    before { sign_in admin }

    describe "#destroy" do
      it "raises a routing error" do
        a = create :attendee
        expect { delete :destroy, :id => a.id, :year => a.year
          }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
