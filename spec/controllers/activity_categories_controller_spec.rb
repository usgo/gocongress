require "rails_helper"

RSpec.describe ActivityCategoriesController, :type => :controller do
  let(:activity_category) { create :activity_category }
  render_views

  it_behaves_like "an admin controller", :activity_category do
    let(:extra_params_for_create) { { :activity_category => { :name => "Name" } } }
    let(:updateable_attribute) { :description }
  end

  describe "#show" do
    it "is successful for visitors" do
      c = create :activity_category
      get :show, params: { year: Time.now.year, id: c.id }
      expect(response).to be_successful
      expect(assigns[:activities_by_date]).not_to be_nil
    end
  end

  describe "#update" do
    it "succeeds" do
      sign_in create :admin
      expect {
        patch :update, params: { year: activity_category.year,
          id: activity_category.id, activity_category: { name: "Activity" } }
      }.to change{ activity_category.reload.name }.to("Activity")
    end
  end
end
