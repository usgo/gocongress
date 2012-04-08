require "spec_helper"

describe AttendeesController do
  let(:user) { FactoryGirl.create :user }
  before do
    sign_in user
  end

  describe "#destroy" do
    it "destroys the attendee" do
      expect {
        delete :destroy, :id => user.attendees.first.id, :year => user.year
      }.to change{ user.attendees.count }.by(-1)
      response.should redirect_to user_path(user)
    end
  end

  describe "#update" do
    let(:attendee) { FactoryGirl.create :attendee, :user => user }

    describe "events page" do
      let(:event) { FactoryGirl.create :event }

      def submit_events_page arpt_date, arpt_time
        put :update,
          attendee: {
            :airport_arrival_date => arpt_date,
            :airport_arrival_time => arpt_time
          },
          event_ids: [event.id],
          id: attendee.id,
          page: 'events',
          year: attendee.year
      end

      it "updates valid airport datetimes" do
        d = "#{attendee.year}-01-01"
        submit_events_page d, "8:00 PM"
        attendee.reload
        attendee.airport_arrival.should be_present
        attendee.airport_arrival.strftime("%Y-%m-%d %H:%M").should == "#{d} 20:00"
      end

      it "does not update invalid airport date" do
        submit_events_page "1/1/#{attendee.year}", "8:00 PM"
        attendee.reload
        attendee.airport_arrival.should be_nil
        assigns(:attendee).errors[:base].should_not be_empty
      end

      it "does not update invalid airport time" do
        valid_date = "#{attendee.year}-01-01"
        submit_events_page valid_date, "7:77 PM"
        attendee.reload
        attendee.airport_arrival.should be_nil
        assigns(:attendee).errors[:base].should_not be_empty
      end
    end
  end
end
