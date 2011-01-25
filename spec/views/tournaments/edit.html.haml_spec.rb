require 'spec_helper'

describe "tournaments/edit.html.haml" do
  before(:each) do
    @tournament = assign(:tournament, stub_model(Tournament,
      :name => "MyString",
      :time => "MyString",
      :elligible => "MyString",
      :description => "MyText",
      :directors => "MyString"
    ))
  end

  it "renders the edit tournament form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => tournament_path(@tournament), :method => "post" do
      assert_select "input#tournament_name", :name => "tournament[name]"
      assert_select "input#tournament_time", :name => "tournament[time]"
      assert_select "input#tournament_elligible", :name => "tournament[elligible]"
      assert_select "textarea#tournament_description", :name => "tournament[description]"
      assert_select "input#tournament_directors", :name => "tournament[directors]"
    end
  end
end
