require 'spec_helper'

describe "discounts/edit.html.haml" do
  before(:each) do
    @discount = assign(:discount, stub_model(Discount,
      :name => "MyString",
      :amount => "9.99",
      :age_min => 1,
      :age_max => 1,
      :is_automatic => false
    ))
  end

  it "renders the edit discount form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => discounts_path(@discount), :method => "post" do
      assert_select "input#discount_name", :name => "discount[name]"
      assert_select "input#discount_amount", :name => "discount[amount]"
      assert_select "input#discount_age_min", :name => "discount[age_min]"
      assert_select "input#discount_age_max", :name => "discount[age_max]"
      assert_select "input#discount_is_automatic", :name => "discount[is_automatic]"
    end
  end
end
