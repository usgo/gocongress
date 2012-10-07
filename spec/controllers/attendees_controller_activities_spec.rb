require "spec_helper"

describe AttendeesController do
  let(:attendee) { FactoryGirl.create :attendee }
  let(:user) { attendee.user }
  let(:admin) { FactoryGirl.create :admin }
  let(:activities) { 1.upto(3).map{ FactoryGirl.create :activity } }

  describe "#update" do
    context "as a user" do
      before(:each) { sign_in user }

      it "can add activities to their own attendee" do
        expect { update_activities(attendee, activities) }.to \
          change { attendee.activities.count }.by(activities.length)
      end

      it "cannot add activities to attendee belonging to someone else" do
        attendee2 = FactoryGirl.create :attendee
        expect { update_activities(attendee2, activities) }.to_not \
          change { attendee2.activities.count }
        response.status.should == 403
      end

      it "cannot add disabled activities" do
        activities << FactoryGirl.create(:activity, disabled: true)
        expect { update_activities(attendee, activities) }.to_not \
          change { attendee.activities.count }
      end
    end

    context "as an admin" do
      it "allows an admin to add activities to any attendee" do
        sign_in admin
        expect { update_activities(attendee, activities) }.to \
          change { attendee.activities.count }.by(activities.length)
      end
    end

    def update_activities attendee, activities
      put :update, :id => attendee.id, \
        :attendee => { :activity_id_list => activities.map(&:id) }, \
        :page => 'basics', :year => attendee.year
    end

  end
end
