require 'spec_helper'

describe "discounts/show.html.haml" do
  before(:each) do
    @discount = assign(:discount, stub_model(Discount,
      :name => "Name",
      :amount => "9.99",
      :age_min => 1,
      :age_max => 1,
      :is_automatic => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/9.99/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
  end
end
