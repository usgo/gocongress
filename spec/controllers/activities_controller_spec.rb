require "spec_helper"

describe ActivitiesController do
  it_behaves_like "an admin controller", :activity do
    let(:cat) { FactoryGirl.create :activity_category }
    let(:extra_params_for_create) { {:activity => {:activity_category_id => cat.id}} }
    let(:updateable_attribute) { :notes }
  end
end
