require "spec_helper"

describe PlansController do
  describe "DELETE destroy" do
    it "fails when attendees have selected the plan" do
      plan = Factory :plan
      plan.attendees << Factory(:attendee)
      sign_in Factory :admin
      expect {
        delete :destroy, year: plan.year, id: plan.id
      }.to_not change{ Plan.count }
      flash[:alert].should == "Cannot delete plan because attendees have already selected it"
      response.should redirect_to(plan_path(plan))
    end
  end
end
