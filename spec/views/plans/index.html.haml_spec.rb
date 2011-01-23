require 'spec_helper'

describe "plans/index.html.haml" do
  before(:each) do
    assign(:plans, [
      stub_model(Plan,
        :name => "Name",
        :description => "Description",
        :price => "9.99",
        :age_min => 1,
        :age_max => 1
      ),
      stub_model(Plan,
        :name => "Name",
        :description => "Description",
        :price => "9.99",
        :age_min => 1,
        :age_max => 1
      )
    ])
  end

  it "renders a list of plans" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
