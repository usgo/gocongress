require "spec_helper"

describe PlansController do
  let(:plan) { FactoryGirl.create :plan }

  context 'as a visitor' do
    it 'can show plan' do
      get :show, :id => plan.id, :year => plan.year
      response.should be_successful
    end
  end

  context 'as a user' do
    it 'cannot get new' do
      sign_in FactoryGirl.create :user
      get :new, :year => Time.now.year
      response.should be_forbidden
    end

    it 'cannot create' do
      sign_in FactoryGirl.create :user
      attrs = accessible_attributes_for plan
      post :create, :plan => attrs, :year => Time.now.year
      response.should be_forbidden
    end
  end

  context 'as an admin' do
    let(:admin) { FactoryGirl.create :admin }
    before do sign_in admin end

    it 'can create' do
      attrs = accessible_attributes_for plan
      expect { post :create, :plan => attrs, :year => plan.year
        }.to change { Plan.count }.by(+1)
      response.should redirect_to plan_category_path plan.plan_category
    end

    it 'cannot destroy when attendees have selected the plan' do
      plan = FactoryGirl.create :plan
      plan.attendees << FactoryGirl.create(:attendee)
      expect {
        delete :destroy, year: plan.year, id: plan.id
      }.to_not change{ Plan.count }
      flash[:alert].should == 'Cannot delete plan because attendees have already selected it'
      response.should redirect_to(plan_path(plan))
    end

    it 'can update max quantity' do
      new_max_quantity = 100+rand(10)
      plan.max_quantity.should_not == new_max_quantity
      attrs = accessible_attributes_for(plan).merge(max_quantity: new_max_quantity)
      put :update, :id => plan.id, :plan => attrs, :year => plan.year
      Plan.find(plan.id).max_quantity.should == new_max_quantity
      response.should redirect_to plan_category_path plan.plan_category
    end
  end
end
