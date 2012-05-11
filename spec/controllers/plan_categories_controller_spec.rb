require "spec_helper"

describe PlanCategoriesController do
  let(:cat) { FactoryGirl.create :plan_category }
  let!(:plan) { FactoryGirl.create :plan, disabled: true, plan_category: cat }

  describe "#destroy" do
    it "Admin should get a friendly warning when they try to delete a Plan Category that is in use" do
      sign_in FactoryGirl.create(:admin)
      plan.attendees << FactoryGirl.build(:attendee)
      expect { delete :destroy, id: cat.id, year: cat.year
        }.to_not change{ PlanCategory.count }
      flash[:alert].should include "Cannot delete the '#{cat.name}' category"
    end
  end

  describe "GET show" do
    it "user cannot see disabled plans" do
      user = FactoryGirl.create :user
      sign_in user
      get :show, year: cat.year, id: cat.id
      assigns(:plans).map(&:id).should_not include(plan.id)
    end

    it "admin can see disabled plans" do
      admin = FactoryGirl.create :admin
      sign_in admin
      get :show, year: cat.year, id: cat.id
      assigns(:plans).map(&:id).should include(plan.id)
    end
  end
end
