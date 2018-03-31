require "rails_helper"

RSpec.describe PlansController, :type => :controller do
  let(:category) { create :plan_category }
  let(:plan) { create :plan, plan_category_id: category.id }
  let(:plan_attributes) { { :price => 1, :name => "Plan", :description => "Description", :age_min => 0 } }

  context 'as a visitor' do
    it 'can show plan' do
      get :show, params: { id: plan.id, year: plan.year }
      expect(response).to be_successful
    end
  end

  context 'as a user' do
    it 'cannot get new' do
      sign_in create :user
      get :new, params: { year: Time.now.year }
      expect(response).to be_forbidden
    end

    it 'cannot create' do
      sign_in create :user
      post :create, params: { year: Time.now.year, plan: { price: 1, name: "Plan", description: "Description", age_min: 0, plan_category_id: category.id } }
      expect(response).to be_forbidden
    end
  end

  context 'as an admin' do
    let(:admin) { create :admin }
    before do sign_in admin end

    it 'can create' do
      expect {
        post :create, params: { year: Time.now.year, plan: { price: 1, name: "Plan", description: "Description", age_min: 0, plan_category_id: category.id } }
      }.to change { Plan.count }.by(+1)
      expect(response).to redirect_to plan_category_path plan.plan_category
    end

    it 'cannot destroy when attendees have selected the plan' do
      plan = create :plan
      plan.attendees << create(:attendee)
      expect {
        delete :destroy, params: { year: plan.year, id: plan.id }
      }.to_not change{ Plan.count }
      expect(flash[:alert]).to eq('Cannot delete plan because attendees have already selected it.')
      expect(response).to redirect_to(plan_path(plan))
    end

    it 'can update max quantity' do
      new_max_quantity = 100+rand(10)
      expect(plan.max_quantity).not_to eq(new_max_quantity)
      attrs = plan_attributes.merge(max_quantity: new_max_quantity)
      patch :update, params: { id: plan.id, plan: attrs, year: plan.year }
      expect(Plan.find(plan.id).max_quantity).to eq(new_max_quantity)
      expect(response).to redirect_to plan_category_path plan.plan_category
    end
  end
end
