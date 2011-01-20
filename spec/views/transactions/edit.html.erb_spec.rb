require 'spec_helper'

describe "transactions/edit.html.erb" do
  before(:each) do
    @transaction = assign(:transaction, stub_model(Transaction,
      :userid => 1,
      :trantype => "MyString",
      :amount => "9.99",
      :gwtranid => 1
    ))
  end

  it "renders the edit transaction form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => transaction_path(@transaction), :method => "post" do
      assert_select "input#transaction_userid", :name => "transaction[userid]"
      assert_select "input#transaction_trantype", :name => "transaction[trantype]"
      assert_select "input#transaction_amount", :name => "transaction[amount]"
      assert_select "input#transaction_gwtranid", :name => "transaction[gwtranid]"
    end
  end
end
