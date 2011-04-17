require 'spec_helper'

describe "plan_categories/show.html.haml" do
  before(:each) do
    @plan_category = assign(:plan_category, stub_model(PlanCategory,
      :name => "Name",
      :show_on_prices_page => false,
      :show_on_roomboard_page => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
  end
end
