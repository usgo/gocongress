require "rails_helper"

RSpec.describe ActivitiesController, :type => :controller do
  it_behaves_like "an admin controller", :activity do
    let(:cat) { create :activity_category }
    let(:extra_params_for_create) { { :activity => { :activity_category_id => cat.id, :leave_time => DateTime.current + 2.days, :name => "Activity", :price => 1, :return_time => Time.current + 3.days } } }
    let(:updateable_attribute) { :notes }
  end

  context "as a visitor" do
    describe "#show" do
      it "succeeds" do
        activity = create(:activity)
        get :show, params: { year: Time.now.year, id: activity.id }
        expect(response).to be_successful
      end
    end
  end

  context "as a user" do
    let(:activity_category) { create(:activity_category) }
    let(:user) { create(:user) }
    before(:each) do
      sign_in user
    end
    describe "#create" do
      it "is forbidden" do
        post :create, params: { year: Time.now.year,
          activity: { activity_category_id: activity_category.id, leave_time: DateTime.current + 2.days, name: "Activity", price: 1, return_time: Time.current + 3.days } }
        expect(response.status).to eq(403)
      end
    end
    describe "#new" do
      it "is forbidden" do
        get :new, params: { year: Time.now.year }
        expect(response.status).to eq(403)
      end
    end
  end
end
