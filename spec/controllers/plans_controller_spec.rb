require "spec_helper"

describe PlansController do
  describe '#destroy' do
    it 'fails when attendees have selected the plan' do
      plan = FactoryGirl.create :plan
      plan.attendees << FactoryGirl.create(:attendee)
      sign_in FactoryGirl.create :admin
      expect {
        delete :destroy, year: plan.year, id: plan.id
      }.to_not change{ Plan.count }
      flash[:alert].should == 'Cannot delete plan because attendees have already selected it'
      response.should redirect_to(plan_path(plan))
    end
  end
end
