require 'spec_helper'

describe "plan_categories/new.html.haml" do
  before(:each) do
    assign(:plan_category, stub_model(PlanCategory,
      :name => "MyString",
      :show_on_prices_page => false,
      :show_on_roomboard_page => false
    ).as_new_record)
  end

  it "renders new plan_category form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => plan_categories_path, :method => "post" do
      assert_select "input#plan_category_name", :name => "plan_category[name]"
      assert_select "input#plan_category_show_on_prices_page", :name => "plan_category[show_on_prices_page]"
      assert_select "input#plan_category_show_on_roomboard_page", :name => "plan_category[show_on_roomboard_page]"
    end
  end
end
