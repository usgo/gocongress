require "spec_helper"

describe AttendeesController do
  let(:user) { FactoryGirl.create :user }
  let(:attendee) { user.attendees.first }
  let(:admin) { FactoryGirl.create :admin }
  let(:activities) { 1.upto(3).map{ FactoryGirl.create :activity } }

  describe "#update" do

    it "allows a user to add activities to their own attendee" do
      sign_in user
      expect { update_activities(attendee) }.to \
        change { attendee.activities.count }.by(activities.length)
      response.should redirect_to user_path(user)
    end

    it "does not allow a user to add activities to an attendee belonging to someone else" do
      sign_in user
      attendee2 = FactoryGirl.create :attendee
      expect { update_activities(attendee2) }.to_not \
        change { attendee2.activities.count }
      response.status.should == 403
    end

    it "allows an admin to add activities to any attendee" do
      sign_in admin
      expect { update_activities(attendee) }.to \
        change { attendee.activities.count }.by(activities.length)
      response.should redirect_to user_path(user)
    end

    def update_activities attendee
      put :update, :id => attendee.id, \
        :attendee => { :activity_id_list => activities.map(&:id) }, \
        :page => 'activities', :year => attendee.year
    end

  end
end
