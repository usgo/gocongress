require "rails_helper"

RSpec.describe ActivityCategoriesController, :type => :controller do
  render_views

  it_behaves_like "an admin controller", :activity_category do
    let(:updateable_attribute) { :description }
  end

  describe "#show" do
    it "is successful for visitors" do
      c = create :activity_category
      get :show, :year => Time.now.year, :id => c.id
      expect(response).to be_successful
      expect(assigns[:activities_by_date]).not_to be_nil
    end
  end
end
