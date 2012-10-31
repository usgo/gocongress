require "spec_helper"

describe PlanCategoriesController do
  it_behaves_like "an admin controller", :plan_category do
    let(:event) { create :event }
    let(:extra_params_for_create) { {:plan_category => {:event_id => event.id}} }
    let(:updateable_attribute) { :description }
  end

  let(:cat) { create :plan_category }
  let!(:plan) { create :plan, disabled: true, plan_category: cat }

  describe "#destroy" do
    context "when the Plan Category is in use" do
      before(:each) do
        plan.attendees << build(:attendee)
      end
      it "admin should get a friendly warning" do
        sign_in create(:admin)
        expect { delete :destroy, id: cat.id, year: cat.year
          }.to_not change{ PlanCategory.count }
        flash[:alert].should include "Cannot delete the '#{cat.name}' category"
      end
    end
  end

  describe "#index" do
    it "allows visitors" do
      get :index, year: cat.year
      response.should be_success
      assigns(:plan_categories).should_not be_empty
    end
  end

  describe "#show" do
    it "allows visitors" do
      get :show, id: cat.id, year: cat.year
      response.should be_success
      assigns(:plan_category).should_not be_nil
    end

    it "user cannot see disabled plans" do
      user = create :user
      sign_in user
      get :show, year: cat.year, id: cat.id
      assigns(:plans).map(&:id).should_not include(plan.id)
    end

    it "admin can see disabled plans" do
      admin = create :admin
      sign_in admin
      get :show, year: cat.year, id: cat.id
      assigns(:plans).map(&:id).should include(plan.id)
    end
  end
end
