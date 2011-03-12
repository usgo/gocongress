require 'spec_helper'

describe "contents/new.html.haml" do
  before(:each) do
    assign(:content, stub_model(Content,
      :body => "MyText",
      :subject => "MyString",
      :show_on_homepage => false
    ).as_new_record)
  end

  it "renders new content form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => contents_path, :method => "post" do
      assert_select "textarea#content_body", :name => "content[body]"
      assert_select "input#content_subject", :name => "content[subject]"
      assert_select "input#content_show_on_homepage", :name => "content[show_on_homepage]"
    end
  end
end
