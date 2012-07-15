require "spec_helper"

describe ActivityCategoriesController do
  it_behaves_like "an admin controller", :activity_category do
    let(:updateable_attribute) { :description }
  end

  let(:cat){ FactoryGirl.create :activity_category }

  it "admin can delete" do
    sign_in FactoryGirl.create :admin
    delete :destroy, {:id => cat.id, :year => cat.year}
    ActivityCategory.all.should_not include(cat)
  end

  it "user cannot delete" do
    sign_in FactoryGirl.create :user
    delete :destroy, {:id => cat.id, :year => cat.year}
    ActivityCategory.all.should include(cat)
  end
end
