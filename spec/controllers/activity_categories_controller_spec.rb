require "spec_helper"

describe ActivityCategoriesController do
  it_behaves_like "an admin controller", :activity_category do
    let(:updateable_attribute) { :description }
  end

  describe "#show" do
    it "is successful for visitors" do
      c = FactoryGirl.create :activity_category
      get :show, :year => Time.now.year, :id => c.id
      response.should be_successful
      assigns[:activities_by_date].should_not be_nil
    end
  end
end
