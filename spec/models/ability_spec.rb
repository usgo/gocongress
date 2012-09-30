require "spec_helper"

describe Ability do
  describe ".explain_denial" do
    let(:coin_toss) { [true,false].sample }
    it "says you are authenticated" do
      msg = Ability.explain_denial true, :foo, "bar"
      msg.should include 'You are signed in'
    end
    it "says you are not authenticated" do
      msg = Ability.explain_denial false, :foo, "bar"
      msg.should include 'You are not signed in'
    end
    it "includes the action taken and the controller name" do
      msg = Ability.explain_denial coin_toss, :foo, 'bar'
      msg.should include 'foo'
      msg.should include 'bar'
    end
    it "describes create action" do
      msg = Ability.explain_denial coin_toss, :create, 'bananas'
      msg.should include 'create bananas'
    end
    it "describes destroy action" do
      msg = Ability.explain_denial coin_toss, :destroy, 'bananas'
      msg.should include 'delete this banana'
    end
    it "describes index action" do
      msg = Ability.explain_denial coin_toss, :index, 'bananas'
      msg.should include 'list bananas'
    end
    it "describes show action" do
      msg = Ability.explain_denial coin_toss, :show, 'bananas'
      msg.should include 'see this banana'
    end
  end
end

