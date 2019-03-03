require "rails_helper"

RSpec.describe PlanCategoriesController, :type => :controller do
  render_views

  it_behaves_like "an admin controller", :plan_category do
    let(:event) { create :event }
    let(:extra_params_for_create) { {:plan_category => {:event_id => event.id, :name => "Plan Category"}} }
    let(:updateable_attribute) { :description }
  end

  let(:event) { create :event }
  let(:cat) { create :plan_category }
  let!(:plan) { create :plan, disabled: true, plan_category: cat }

  describe "#destroy" do
    context "when the Plan Category is in use" do
      before(:each) do
        plan.attendees << build(:attendee)
      end
      it "admin should get a friendly warning" do
        sign_in create(:admin)
        expect {
          delete :destroy, params: { id: cat.id, year: cat.year }
        }.to_not change{ PlanCategory.count }
        expect(flash[:alert]).to include "Cannot delete the '#{cat.name}' category"
      end
    end
  end

  describe "#index" do
    it "allows visitors" do
      get :index, params: { year: cat.year }
      if cat.year == 2019
        expect(response.status).to eq(302)
      else
        expect(response).to be_success
      end
      expect(assigns(:plan_categories)).not_to be_empty
    end
  end

  describe "#show" do
    it "allows visitors" do
      get :show, params: { id: cat.id, year: cat.year }
      expect(response).to be_success
      expect(assigns(:plan_category)).not_to be_nil
    end

    it "user cannot see disabled plans" do
      user = create :user
      sign_in user
      get :show, params: { year: cat.year, id: cat.id }
      expect(assigns(:plans).map(&:id)).not_to include(plan.id)
    end

    it "admin can see disabled plans" do
      admin = create :admin
      sign_in admin
      get :show, params: { year: cat.year, id: cat.id }
      expect(assigns(:plans).map(&:id)).to include(plan.id)
    end
  end

  describe '#update' do
    it 'admin can reorder plans' do
      sign_in create :admin
      cat = create(:plan_category)
      create(:plan, name: 'Apples', cat_order: 1, plan_category: cat)
      create(:plan, name: 'Oranges', cat_order: 2, plan_category: cat)
      patch :update, params: { year: cat.year, id: cat.id, plan_order: [2,1], plan_category: { event_id: event.id, name: "Plan Category" } }
      expect(response).to redirect_to cat
      expect(cat.plans.order(:cat_order).map(&:name)).to match_array(['Oranges', 'Apples'])
    end
  end
end
