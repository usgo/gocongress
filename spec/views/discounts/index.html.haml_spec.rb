require 'spec_helper'

describe "discounts/index.html.haml" do
  before(:each) do
    assign(:discounts, [
      stub_model(Discount,
        :name => "Name",
        :amount => "9.99",
        :age_min => 1,
        :age_max => 1,
        :is_automatic => false
      ),
      stub_model(Discount,
        :name => "Name",
        :amount => "9.99",
        :age_min => 1,
        :age_max => 1,
        :is_automatic => false
      )
    ])
  end

  it "renders a list of discounts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
