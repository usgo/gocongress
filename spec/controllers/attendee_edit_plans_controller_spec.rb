require "spec_helper"

describe AttendeesController do
  describe "PUT update_plans" do
    let(:user) { Factory :user }
    before(:each) do
      sign_in user
    end

    context "when the category is mandatory" do
      let(:cat) { Factory :plan_category, mandatory: true }
      let!(:plan) { Factory :all_ages_plan, plan_category: cat }

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
          expect {
            put :update_plans,
              year: 2012,
              id: user.primary_attendee.id,
              plan_category_id: cat.id,
              attendee: {:"plan_#{plan.id}_qty" => 1}
          }.to change{user.primary_attendee.plans.count}.from(0).to(1)
        end
      end

    end
  end

end
