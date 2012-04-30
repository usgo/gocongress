require "spec_helper"

describe AttendeesController do
  let(:user) { FactoryGirl.create :user }
  let(:attendee) { user.attendees.first }
  let(:admin) { FactoryGirl.create :admin }
  let(:act1) { FactoryGirl.create :activity }
  let(:act2) { FactoryGirl.create :activity }

  describe "#update" do

    it "user can add activities to own attendee" do
      sign_in user
      expect { update_activities(attendee) }.to \
        change { attendee.activities.count }.by(2)
      response.should redirect_to user_path(user)
    end

    it "user cannot add activities to attendee belonging to someone else" do
      sign_in user
      attendee2 = FactoryGirl.create :attendee
      expect { update_activities(attendee2) }.to_not \
        change { attendee2.activities.count }
      response.status.should == 403
    end

    it "admin can add activities to attendee belonging to someone else" do
      sign_in admin
      expect { update_activities(attendee) }.to \
        change { attendee.activities.count }.by(2)
      response.should redirect_to user_path(user)
    end

    def update_activities attendee
      put :update, :id => attendee.id, \
        :attendee => {:activity_id_list => [act1.id, act2.id]}, \
        :page => 'activities', :year => attendee.year
    end

  end
end
