require "spec_helper"

describe PlansController, :type => :controller do
  let(:plan) { create :plan }

  context 'as a visitor' do
    it 'can show plan' do
      get :show, :id => plan.id, :year => plan.year
      expect(response).to be_successful
    end
  end

  context 'as a user' do
    it 'cannot get new' do
      sign_in create :user
      get :new, :year => Time.now.year
      expect(response).to be_forbidden
    end

    it 'cannot create' do
      sign_in create :user
      attrs = accessible_attributes_for plan
      post :create, :plan => attrs, :year => Time.now.year
      expect(response).to be_forbidden
    end
  end

  context 'as an admin' do
    let(:admin) { create :admin }
    before do sign_in admin end

    it 'can create' do
      attrs = accessible_attributes_for plan
      expect { post :create, :plan => attrs, :year => plan.year
        }.to change { Plan.count }.by(+1)
      expect(response).to redirect_to plan_category_path plan.plan_category
    end

    it 'cannot destroy when attendees have selected the plan' do
      plan = create :plan
      plan.attendees << create(:attendee)
      expect {
        delete :destroy, year: plan.year, id: plan.id
      }.to_not change{ Plan.count }
      expect(flash[:alert]).to eq('Cannot delete plan because attendees have already selected it')
      expect(response).to redirect_to(plan_path(plan))
    end

    it 'can update max quantity' do
      new_max_quantity = 100+rand(10)
      expect(plan.max_quantity).not_to eq(new_max_quantity)
      attrs = accessible_attributes_for(plan).merge(max_quantity: new_max_quantity)
      put :update, :id => plan.id, :plan => attrs, :year => plan.year
      expect(Plan.find(plan.id).max_quantity).to eq(new_max_quantity)
      expect(response).to redirect_to plan_category_path plan.plan_category
    end
  end
end
