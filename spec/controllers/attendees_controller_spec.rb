require "spec_helper"

describe AttendeesController do
  render_views
  let(:activities) { 1.upto(3).map{ create :activity } }

  context "as a visitor" do
    describe "#index" do
      render_views

      it "succeeds" do
        a = create :attendee
        Attendee::WhoIsComing.any_instance.stub(:find_attendees) { [a] }
        Year.any_instance.stub(:registration_phase) { :open }
        get :index, :year => Time.current.year
        response.should be_successful
        assigns(:who_is_coming).should_not be_nil
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
