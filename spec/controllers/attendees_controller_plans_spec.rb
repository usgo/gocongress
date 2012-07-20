require "spec_helper"

describe AttendeesController do
  let(:attendee) { FactoryGirl.create :attendee }

  before(:each) do
    sign_in attendee.user
  end

  describe "#edit_plans" do

    it "shows disabled plans, but only if attendee already has them" do
      plan = FactoryGirl.create :plan, :disabled => true
      attendee.plans << plan
      attendee.get_plan_qty(plan.id).should == 1

      plan2 = FactoryGirl.create :plan, :disabled => true, \
        :name => "Plan Deux", :plan_category => plan.plan_category

      get :edit_plans,
        :id => attendee.id,
        :plan_category_id => plan.plan_category.id,
        :year => attendee.year

      assigns(:plans).should include(plan)
      assigns(:plans).map(&:name).should_not include(plan2.name)
    end
  end

  describe "PUT update_plans" do

    it "updates the attendee's plans in the specified category" do
      plan = FactoryGirl.create :plan
      put_to_update_plans plan
      attendee.plans.should include(plan)
    end

    context "when attendee selects a disabled plan" do
      let(:plan) { FactoryGirl.create :plan, disabled: true }

      context "and attendee already has that disabled plan" do
        before do
          attendee.plans << plan
        end

        it "should allow attendee to keep the plan" do
          put_to_update_plans plan
          attendee.plans.should include(plan)
        end
      end

      context "and attendee does not already have that disabled plan" do
        it "should not allow attendee to select the disabled plan" do
          put_to_update_plans plan
          attendee.plans.should_not include(plan)
        end
      end
    end

    context "when attendee un-selects a disabled plan" do
      let(:plan) { FactoryGirl.create :plan, disabled: true, name: "Numero Uno" }
      let(:plan2) { FactoryGirl.create :plan, name: "Deux", :plan_category => plan.plan_category }
      before do
        attendee.plans << plan
      end

      it "does not allow them to un-select the plan" do
        put :update_plans,
          year: 2012,
          id: attendee.id,
          plan_category_id: plan.plan_category.id,
          attendee: {:"plan_#{plan2.id}_qty" => 1}
        attendee.reload
        attendee.plans.map(&:name).should include(plan.name)
        response.should render_template(:edit_plans)
      end
    end

    context "when the category is mandatory" do
      let(:cat) { FactoryGirl.create :plan_category, mandatory: true }
      let!(:plan) { FactoryGirl.create :plan, plan_category: cat }

      context "when the attendee selects zero plans" do
        it "stays on the same page" do
          put :update_plans,
            year: 2012,
            id: attendee.id,
            plan_category_id: cat.id,
            attendee: {}

          response.code.should == "200"
          response.should render_template(:edit_plans)
          assigns(:plan_category).should == cat # AR will compare ids
        end
      end

      context "when the attendee selects one plan" do
        it "saves an AttendeePlan record" do
          expect { put_to_update_plans plan }.to \
            change{ attendee.plans.count }.from(0).to(1)
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
    id: attendee.id,
    plan_category_id: plan.plan_category.id,
    attendee: {:"plan_#{plan.id}_qty" => 1}
end
