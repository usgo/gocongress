require 'spec_helper'

describe "plan_categories/index.html.haml" do
  before(:each) do
    assign(:plan_categories, [
      stub_model(PlanCategory,
        :name => "Name",
        :show_on_prices_page => false,
        :show_on_roomboard_page => false
      ),
      stub_model(PlanCategory,
        :name => "Name",
        :show_on_prices_page => false,
        :show_on_roomboard_page => false
      )
    ])
  end

  it "renders a list of plan_categories" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
