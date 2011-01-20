require 'spec_helper'

describe "transactions/show.html.erb" do
  before(:each) do
    @transaction = assign(:transaction, stub_model(Transaction,
      :userid => 1,
      :trantype => "Trantype",
      :amount => "9.99",
      :gwtranid => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Trantype/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/9.99/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
