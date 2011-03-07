require 'spec_helper'

describe "discounts/new.html.haml" do
  before(:each) do
    assign(:discount, stub_model(Discount,
      :name => "MyString",
      :amount => "9.99",
      :age_min => 1,
      :age_max => 1,
      :is_automatic => false
    ).as_new_record)
  end

  it "renders new discount form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => discounts_path, :method => "post" do
      assert_select "input#discount_name", :name => "discount[name]"
      assert_select "input#discount_amount", :name => "discount[amount]"
      assert_select "input#discount_age_min", :name => "discount[age_min]"
      assert_select "input#discount_age_max", :name => "discount[age_max]"
      assert_select "input#discount_is_automatic", :name => "discount[is_automatic]"
    end
  end
end
