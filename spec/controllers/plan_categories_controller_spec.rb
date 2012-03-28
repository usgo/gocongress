require "spec_helper"

describe PlanCategoriesController do
  describe "GET show" do
    let(:cat) { FactoryGirl.create :plan_category }
    let!(:plan) { FactoryGirl.create :plan, disabled: true, plan_category: cat }

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
