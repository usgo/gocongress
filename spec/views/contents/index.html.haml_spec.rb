require 'spec_helper'

describe "contents/index.html.haml" do
  before(:each) do
    assign(:contents, [
      stub_model(Content,
        :body => "MyText",
        :subject => "Subject",
        :show_on_homepage => false
      ),
      stub_model(Content,
        :body => "MyText",
        :subject => "Subject",
        :show_on_homepage => false
      )
    ])
  end

  it "renders a list of contents" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Subject".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
