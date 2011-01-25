require 'spec_helper'

describe "tournaments/show.html.haml" do
  before(:each) do
    @tournament = assign(:tournament, stub_model(Tournament,
      :name => "Name",
      :time => "Time",
      :elligible => "Elligible",
      :description => "MyText",
      :directors => "Directors"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Time/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Elligible/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Directors/)
  end
end
