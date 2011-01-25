require 'spec_helper'

describe "tournaments/index.html.haml" do
  before(:each) do
    assign(:tournaments, [
      stub_model(Tournament,
        :name => "Name",
        :time => "Time",
        :elligible => "Elligible",
        :description => "MyText",
        :directors => "Directors"
      ),
      stub_model(Tournament,
        :name => "Name",
        :time => "Time",
        :elligible => "Elligible",
        :description => "MyText",
        :directors => "Directors"
      )
    ])
  end

  it "renders a list of tournaments" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Time".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Elligible".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Directors".to_s, :count => 2
  end
end
