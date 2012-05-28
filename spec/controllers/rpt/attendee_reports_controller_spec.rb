require "spec_helper"
require "controllers/rpt/shared_examples_for_reports"

describe Rpt::AttendeeReportsController do
  it_behaves_like "a report", %w[html csv]

  describe "#show" do
    let(:staff) { FactoryGirl.create :staff }
    let(:plan) { FactoryGirl.create :plan }
    let!(:atnd) { FactoryGirl.create :attendee, :given_name => "Plan Man" }

    before(:each) do
      atnd.plans << plan
      sign_in staff
    end

    context "when planlessness is not specified" do
      it "finds all attendees" do
        get :show, :year => staff.year
        assigns(:attendees).should =~ [atnd, staff.primary_attendee]
      end
    end

    context "when planlessness = all" do
      it "finds all attendees" do
        get :show, :year => staff.year, :planlessness => :all
        assigns(:attendees).should =~ [atnd, staff.primary_attendee]
      end
    end

    context "when planlessness = planful" do
      it "finds attendees with plans" do
        get :show, :year => staff.year, :planlessness => :planful
        assigns(:attendees).should =~ [atnd]
      end
    end

    context "when planlessness = planless" do
      it "finds attendees with no plans" do
        get :show, :year => staff.year, :planlessness => :planless
        assigns(:attendees).should =~ [staff.primary_attendee]
      end
    end
  end
end
