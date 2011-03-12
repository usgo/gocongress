require 'spec_helper'

describe "contents/show.html.haml" do
  before(:each) do
    @content = assign(:content, stub_model(Content,
      :body => "MyText",
      :subject => "Subject",
      :show_on_homepage => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Subject/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
  end
end
