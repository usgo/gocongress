require "spec_helper"

describe PlanCategoriesController do
  describe "GET show" do
    let(:cat) { Factory :plan_category }
    let!(:plan) { Factory :plan, disabled: true, plan_category: cat }

    it "user cannot see disabled plans" do
      user = Factory :user
      sign_in user
      get :show, year: cat.year, id: cat.id
      assigns(:plans).map(&:id).should_not include(plan.id)
    end

    it "admin can see disabled plans" do
      admin = Factory :admin
      sign_in admin
      get :show, year: cat.year, id: cat.id
      assigns(:plans).map(&:id).should include(plan.id)
    end
  end
end
