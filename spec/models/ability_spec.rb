require "spec_helper"

describe Ability do
  describe ".explain_denial" do
    let(:coin_toss) { [true,false].sample }
    it "says you are authenticated" do
      msg = Ability.explain_denial true, "stub", "stub"
      msg.should include 'You are signed in'
    end
    it "says you are not authenticated" do
      msg = Ability.explain_denial false, "stub", "stub"
      msg.should include 'You are not signed in'
    end
    it "includes the action taken and the controller name" do
      msg = Ability.explain_denial coin_toss, 'action', 'controller'
      msg.should include 'action'
      msg.should include 'controller'
    end
  end
end

