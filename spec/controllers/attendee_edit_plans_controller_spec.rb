require "spec_helper"

describe AttendeesController do
  describe "PUT update_plans" do
    let(:user) { FactoryGirl.create :user }
    before(:each) do
      sign_in user
    end

    it "updates the user's plans in the specified category" do
      plan = FactoryGirl.create :plan
      put_to_update_plans plan
      user.primary_attendee.plans.should include(plan)
    end

    it "does not add disabled plans" do
      plan = FactoryGirl.create :plan, disabled: true
      put_to_update_plans plan
      user.primary_attendee.plans.should_not include(plan)
    end

    context "when the category is mandatory" do
      let(:cat) { FactoryGirl.create :plan_category, mandatory: true }
      let!(:plan) { FactoryGirl.create :plan, plan_category: cat }

      context "when the attendee selects zero plans" do
        it "stays on the same page" do
          put :update_plans,
            year: 2012,
            id: user.primary_attendee.id,
            plan_category_id: cat.id,
            attendee: {}

          response.code.should == "200"
          response.should render_template(:edit_plans)
          assigns(:plan_category).should == cat # AR will compare ids
        end
      end

      context "when the attendee selects one plan" do
        it "saves an AttendeePlan record" do
          expect { put_to_update_plans plan }.to
            change{user.primary_attendee.plans.count}.from(0).to(1)
        end
      end

    end
  end

end

# Spec Helpers
# ------------

def put_to_update_plans plan
  put :update_plans,
    year: 2012,
    id: user.primary_attendee.id,
    plan_category_id: plan.plan_category.id,
    attendee: {:"plan_#{plan.id}_qty" => 1}
end
